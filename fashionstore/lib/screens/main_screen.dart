import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/controllers/main_controller.dart';
import 'package:fashionstore/screens/home_screen.dart';
import 'package:fashionstore/screens/cart_screen.dart';
import 'package:fashionstore/screens/profile_screen.dart';
import 'package:fashionstore/utils/constants.dart';

class MainScreen extends StatelessWidget {
  final MainController controller = Get.put(MainController());

  final List<Widget> screens = [
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: screens,
      )),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: (index) => controller.changeIndex(index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Giỏ hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }
}