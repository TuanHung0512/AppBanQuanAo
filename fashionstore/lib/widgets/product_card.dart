import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/models/product_model.dart';
import 'package:fashionstore/screens/product_detail_screen.dart';
import 'package:fashionstore/utils/constants.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ảnh sản phẩm (Dùng Expanded để tự động chiếm phần không gian còn lại)
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                ),
              ),
            ),
          ),

          // 2. Thông tin sản phẩm (Đã giới hạn số dòng để chống tràn)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1, // ⬅️ Fix lỗi không tràn tên
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.price.toStringAsFixed(0)}đ',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 3. Nút xem chi tiết
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Get.to(() => ProductDetailScreen(product: product)),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.08),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
              ),
              child: const Text('Xem chi tiết', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}