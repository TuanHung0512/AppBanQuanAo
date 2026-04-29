import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/controllers/auth_controller.dart';
import 'package:fashionstore/screens/signup_screen.dart';
import 'package:fashionstore/utils/constants.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool isLoading = false.obs;

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.2),
                    shape: BoxShape.circle,
                    color: Colors.black,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 30, spreadRadius: 1)],
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, size: 52, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 50),

              const Center(
                child: Column(
                  children: [
                    Text(
                      'FASHION STORE',
                      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 4),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'ENTER THE DARK SIDE OF FASHION',
                      style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 55),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => authController.showForgotPasswordDialog(),
                  child: const Text(
                    'QUÊN MẬT KHẨU?',
                    style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Obx(() => SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: isLoading.value ? null : () async {
                    isLoading.value = true;
                    await authController.login(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    isLoading.value = false;
                  },
                  child: isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'ĐĂNG NHẬP',
                    style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 3),
                  ),
                ),
              )),

              const SizedBox(height: 28),

              Center(
                child: TextButton(
                  onPressed: () => Get.to(() => SignupScreen()),
                  child: RichText(
                    text: const TextSpan(
                      text: 'THÀNH VIÊN MỚI? ',
                      style: TextStyle(color: Colors.white38, letterSpacing: 1),
                      children: [
                        TextSpan(
                          text: 'HÃY TẠO TÀI KHOẢN',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}