import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/controllers/auth_controller.dart';
import 'package:fashionstore/utils/constants.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ tên', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()), obscureText: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => authController.register(emailController.text.trim(), passwordController.text.trim(), nameController.text.trim()),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 56)),
                child: const Text('Đăng ký', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              TextButton(onPressed: () => Get.back(), child: const Text('Đã có tài khoản? Đăng nhập')),
            ],
          ),
        ),
      ),
    );
  }
}