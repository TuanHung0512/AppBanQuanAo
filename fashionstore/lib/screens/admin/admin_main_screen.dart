import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/screens/admin/admin_dashboard_screen.dart';
import 'package:fashionstore/screens/admin/admin_products_screen.dart';
import 'package:fashionstore/screens/admin/admin_orders_screen.dart';
import 'package:fashionstore/utils/constants.dart';

class AdminMainScreen extends StatelessWidget {
  final RxInt currentIndex = 0.obs;

  AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const AdminDashboardScreen(),
      const AdminProductsScreen(),
      const AdminOrdersScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Obx(() => IndexedStack(
        index: currentIndex.value,
        children: screens,
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: currentIndex.value,
        onTap: (index) => currentIndex.value = index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Sản phẩm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
        ],
      )),
    );
  }
}