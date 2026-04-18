import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/controllers/auth_controller.dart';
import 'package:fashionstore/utils/constants.dart';
import 'package:fashionstore/screens/admin/admin_main_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = authController.currentUser.value;
      if (user == null) {
        return const Center(child: Text('Chưa đăng nhập'));
      }

      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 16),
            Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(user.email),
            const SizedBox(height: 40),

            // NÚT QUẢN TRỊ
            if (user.isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 28),
                title: const Text('Quản trị', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                subtitle: const Text('Vào Admin Panel'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () => Get.to(() => AdminMainScreen()),   // ← KHÔNG DÙNG const
              ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(fontSize: 18)),
              onTap: () => authController.logout(),
            ),
          ],
        ),
      );
    });
  }
}