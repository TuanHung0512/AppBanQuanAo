import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/controllers/product_controller.dart';
import 'package:fashionstore/widgets/product_card.dart';
import 'package:fashionstore/utils/constants.dart';

class HomeScreen extends StatelessWidget {
  final ProductController productController = Get.put(ProductController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Trạng thái 1: Đang tải
      if (productController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Trạng thái 2: Trống dữ liệu
      if (productController.products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Chưa có sản phẩm nào!', style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.add_to_drive, color: Colors.white),
                label: const Text('Tạo Dữ Liệu Mẫu', style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () => productController.addSampleData(),
              ),
            ],
          ),
        );
      }

      // Trạng thái 3: Hiển thị lưới sản phẩm
      return Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.52,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: productController.products.length,
          itemBuilder: (context, index) => ProductCard(product: productController.products[index]),
        ),
      );
    });
  }
}