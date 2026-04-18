import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/models/product_model.dart';
import 'package:fashionstore/models/cart_item_model.dart';
import 'package:fashionstore/controllers/cart_controller.dart';
import 'package:fashionstore/utils/constants.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final CartController cartController = Get.find<CartController>();

  ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product.imageUrl, width: double.infinity, height: 300, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('${product.price.toStringAsFixed(0)}đ', style: const TextStyle(fontSize: 22, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(product.description),
                  const SizedBox(height: 16),
                  const Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(children: product.sizes.map((size) => Chip(label: Text(size))).toList()),
                  const SizedBox(height: 16),
                  const Text('Màu', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(children: product.colors.map((color) => Chip(label: Text(color))).toList()),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final item = CartItem(product: product, size: product.sizes.first, color: product.colors.first);
                        cartController.addToCart(item);
                      },
                      child: const Text('Thêm vào giỏ hàng', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}