import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/controllers/cart_controller.dart';
import 'package:fashionstore/utils/constants.dart';

class CartScreen extends StatelessWidget {
  final CartController cartController = Get.find<CartController>();

  CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => cartController.cartItems.isEmpty
        ? const Center(child: Text('Giỏ hàng trống', style: TextStyle(fontSize: 18)))
        : Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartController.cartItems.length,
            itemBuilder: (context, index) {
              final item = cartController.cartItems[index];

              return ListTile(
                leading: Image.network(item.product.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                title: Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${item.size} • ${item.color} • SL: ${item.quantity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${item.total.toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => cartController.removeFromCart(index),
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng thanh toán:', style: TextStyle(fontSize: 18)),
                  Text('${cartController.totalPrice.toStringAsFixed(0)}đ',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: cartController.isProcessing.value ? null : () => cartController.checkout(),
                  child: cartController.isProcessing.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Tạo Hóa Đơn & Thanh Toán',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}