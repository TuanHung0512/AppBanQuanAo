import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashionstore/models/user_model.dart';
import 'package:fashionstore/screens/main_screen.dart';
import 'package:fashionstore/screens/login_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<AppUser?> currentUser = Rx<AppUser?>(null);

  static const String ADMIN_EMAIL = 'admin@fashionstore.com';

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        final docRef = _firestore.collection('users').doc(user.uid);
        final doc = await docRef.get();

        bool isAdmin = user.email!.toLowerCase() == ADMIN_EMAIL.toLowerCase();

        if (doc.exists) {
          // LẤY DỮ LIỆU CŨ
          AppUser existingUser = AppUser.fromMap(doc.data()!, user.uid);

          // Nếu là admin email nhưng isAdmin = false → tự động sửa lại
          if (isAdmin && !existingUser.isAdmin) {
            await docRef.update({'isAdmin': true});
            existingUser = existingUser.copyWith(isAdmin: true); // Cập nhật tạm thời
          }

          currentUser.value = existingUser;
        } else {
          // Tạo mới (trường hợp hiếm)
          final newUser = AppUser(
            uid: user.uid,
            email: user.email!,
            name: user.displayName ?? 'User',
            isAdmin: isAdmin,
          );
          await docRef.set(newUser.toMap());
          currentUser.value = newUser;
        }
      } else {
        currentUser.value = null;
      }
    });
  }

  Future<void> register(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(name);

      final bool isAdmin = email.toLowerCase() == ADMIN_EMAIL.toLowerCase();

      final newUser = AppUser(
        uid: cred.user!.uid,
        email: email,
        name: name,
        isAdmin: isAdmin,
      );

      await _firestore.collection('users').doc(cred.user!.uid).set(newUser.toMap());

      Get.snackbar(
        'Thành công',
        isAdmin ? '🎉 Tạo tài khoản ADMIN thành công!' : 'Đăng ký thành công',
        snackPosition: SnackPosition.TOP,
      );
      Get.offAll(() => MainScreen());
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAll(() => MainScreen());
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAll(() => LoginScreen());
  }
}

extension AppUserExtension on AppUser {
  AppUser copyWith({bool? isAdmin}) {
    return AppUser(
      uid: uid,
      email: email,
      name: name,
      photoUrl: photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}