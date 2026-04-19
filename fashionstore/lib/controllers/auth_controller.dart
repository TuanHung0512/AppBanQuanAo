import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashionstore/models/user_model.dart';
import 'package:fashionstore/screens/main_screen.dart';
import 'package:fashionstore/screens/login_screen.dart';
import 'package:fashionstore/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<AppUser?> currentUser = Rx<AppUser?>(null);
  static const String ADMIN_EMAIL = 'admin@fashionstore.com';

  // Lưu mật khẩu mới sau khi đổi (demo - không gửi mail)
  RxString demoPassword = ''.obs;
  RxString demoEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        final docRef = _firestore.collection('users').doc(user.uid);
        final doc = await docRef.get();
        bool isAdmin = user.email!.toLowerCase() == ADMIN_EMAIL.toLowerCase();

        if (doc.exists) {
          AppUser existingUser = AppUser.fromMap(doc.data()!, user.uid);
          if (isAdmin && !existingUser.isAdmin) {
            await docRef.update({'isAdmin': true});
            existingUser = existingUser.copyWith(isAdmin: true);
          }
          currentUser.value = existingUser;
        } else {
          final newUser = AppUser(uid: user.uid, email: user.email!, name: user.displayName ?? 'User', isAdmin: isAdmin);
          await docRef.set(newUser.toMap());
          currentUser.value = newUser;
        }
      } else {
        currentUser.value = null;
      }
    });
  }

  void showForgotPasswordDialog() {
    Get.to(() => const ResetPasswordScreen());
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng nhập đầy đủ email và mật khẩu',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // ===== KIỂM TRA MẬT KHẨU MỚI SAU KHI ĐỔI (QUAN TRỌNG) =====
    if (demoPassword.value.isNotEmpty &&
        demoEmail.value == email &&
        password == demoPassword.value) {
      currentUser.value = AppUser(
        uid: 'demo-uid',
        email: email,
        name: email.split('@')[0],
        isAdmin: email.toLowerCase() == ADMIN_EMAIL.toLowerCase(),
      );
      Get.offAll(() => MainScreen());
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      Get.offAll(() => MainScreen());
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập thất bại';
      if (e.code == 'user-not-found') message = 'Email chưa đăng ký';
      else if (e.code == 'wrong-password') message = 'Mật khẩu không đúng';
      else if (e.code == 'invalid-email') message = 'Email không hợp lệ';
      Get.snackbar('Lỗi', message, snackPosition: SnackPosition.TOP, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể kết nối', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user!.updateDisplayName(name);
      final bool isAdmin = email.toLowerCase() == ADMIN_EMAIL.toLowerCase();
      final newUser = AppUser(uid: cred.user!.uid, email: email, name: name, isAdmin: isAdmin);
      await _firestore.collection('users').doc(cred.user!.uid).set(newUser.toMap());
      Get.snackbar('Thành công', 'Đăng ký thành công', snackPosition: SnackPosition.TOP);
      Get.offAll(() => MainScreen());
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng ký thất bại';
      if (e.code == 'email-already-in-use') message = 'Email đã tồn tại';
      Get.snackbar('Lỗi', message, snackPosition: SnackPosition.TOP, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAll(() => LoginScreen());
  }
}

extension AppUserExtension on AppUser {
  AppUser copyWith({bool? isAdmin}) {
    return AppUser(uid: uid, email: email, name: name, photoUrl: photoUrl, isAdmin: isAdmin ?? this.isAdmin);
  }
}