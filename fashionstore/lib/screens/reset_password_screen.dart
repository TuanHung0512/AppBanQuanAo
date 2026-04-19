import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/controllers/auth_controller.dart';
import 'package:fashionstore/screens/login_screen.dart';
import 'package:fashionstore/utils/constants.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? generatedCode;
  bool isLoading = false;

  void generateCode() {
    setState(() {
      generatedCode = (10000 + DateTime.now().millisecondsSinceEpoch % 90000).toString();
    });
  }

  void resetPassword() {
    final email = emailController.text.trim();
    final code = codeController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (email.isEmpty || code.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (code != generatedCode) {
      Get.snackbar('Lỗi', 'Mã xác nhận không đúng', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (newPass != confirmPass) {
      Get.snackbar('Lỗi', 'Mật khẩu xác nhận không khớp', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (newPass.length < 6) {
      Get.snackbar('Lỗi', 'Mật khẩu phải có ít nhất 6 ký tự', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);

    final auth = Get.find<AuthController>();
    auth.demoPassword.value = newPass;
    auth.demoEmail.value = email;

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => isLoading = false);
      Get.snackbar('Thành công', 'Mật khẩu đã được đặt lại! Vui lòng đăng nhập lại.', backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAll(() => LoginScreen());   // ← QUAY VỀ LOGIN
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Đặt Lại Mật Khẩu'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(child: Icon(Icons.lock_reset, size: 80, color: AppColors.primary)),
            const SizedBox(height: 24),
            const Center(child: Text('Đặt Lại Mật Khẩu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            const Center(child: Text('Tạo mã và nhập mật khẩu mới', style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 32),

            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: generatedCode == null ? generateCode : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50)),
              child: Text(generatedCode == null ? 'TẠO MÃ XÁC NHẬN' : 'MÃ ĐÃ TẠO'),
            ),

            if (generatedCode != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)),
                child: Column(
                  children: [
                    const Text('Mã xác nhận của bạn:', style: TextStyle(color: Colors.green)),
                    const SizedBox(height: 8),
                    SelectableText(generatedCode!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFDB2777))),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              TextField(controller: codeController, decoration: InputDecoration(labelText: 'Nhập mã xác nhận', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 16),
              TextField(controller: newPasswordController, obscureText: true, decoration: InputDecoration(labelText: 'Mật khẩu mới', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 16),
              TextField(controller: confirmPasswordController, obscureText: true, decoration: InputDecoration(labelText: 'Xác nhận mật khẩu mới', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : resetPassword,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ĐẶT LẠI MẬT KHẨU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],

            const SizedBox(height: 16),
            Center(child: TextButton(onPressed: () => Get.back(), child: const Text('Quay lại', style: TextStyle(color: AppColors.primary)))),
          ],
        ),
      ),
    );
  }
}