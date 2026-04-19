import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashionstore/models/product_model.dart';
import 'package:fashionstore/models/cart_item_model.dart';
import 'package:fashionstore/controllers/cart_controller.dart';
import 'package:fashionstore/controllers/auth_controller.dart';
import 'package:fashionstore/utils/constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CartController cartController = Get.find<CartController>();
  String? selectedSize;
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    // Mặc định chọn size và color đầu tiên
    if (widget.product.sizes.isNotEmpty) {
      selectedSize = widget.product.sizes.first;
    }
    if (widget.product.colors.isNotEmpty) {
      selectedColor = widget.product.colors.first;
    }
  }

  // Helper chuyển tên màu thành màu thật để hiển thị vòng tròn
  Color _getColorFromName(String colorName) {
    final name = colorName.toLowerCase();
    if (name.contains('đỏ')) return Colors.red;
    if (name.contains('xanh')) return Colors.blue;
    if (name.contains('đen')) return Colors.black;
    if (name.contains('trắng')) return Colors.white;
    if (name.contains('vàng')) return Colors.amber;
    if (name.contains('xám')) return Colors.grey;
    if (name.contains('hồng')) return AppColors.primary;
    if (name.contains('cam')) return Colors.orange;
    if (name.contains('tím')) return Colors.purple;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            Image.network(
              widget.product.imageUrl,
              width: double.infinity,
              height: 320,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.product.price.toStringAsFixed(0)}đ',
                    style: TextStyle(
                      fontSize: 26,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.product.description),
                  const SizedBox(height: 32),

                  // ==================== CHỌN SIZE ====================
                  const Text(
                    'Chọn Size',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.product.sizes.length,
                      itemBuilder: (context, index) {
                        final size = widget.product.sizes[index];
                        final isSelected = size == selectedSize;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(size, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            onSelected: (_) {
                              setState(() => selectedSize = size);
                            },
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                            backgroundColor: Colors.grey[200],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================== CHỌN MÀU ====================
                  const Text(
                    'Chọn Màu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.product.colors.length,
                      itemBuilder: (context, index) {
                        final colorName = widget.product.colors[index];
                        final isSelected = colorName == selectedColor;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedColor = colorName);
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : Colors.transparent,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: _getColorFromName(colorName),
                                    child: isSelected
                                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  colorName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? AppColors.primary : Colors.grey[700],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ==================== PHẦN ĐÁNH GIÁ SẢN PHẨM (giữ nguyên) ====================
                  const Text(
                    'Đánh giá sản phẩm',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('productId', isEqualTo: widget.product.id)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final reviews = snapshot.data?.docs ?? [];
                      final int reviewCount = reviews.length;

                      if (reviewCount == 0) {
                        return _buildNoReviewSection();
                      }

                      double total = 0;
                      for (var doc in reviews) {
                        total += (doc['rating'] ?? 0).toDouble();
                      }
                      final avgRating = total / reviewCount;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRatingSummary(avgRating, reviewCount),
                          const SizedBox(height: 24),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviewCount,
                            itemBuilder: (context, index) {
                              final review = reviews[index].data() as Map<String, dynamic>;
                              final double rating = (review['rating'] ?? 0).toDouble();

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: AppColors.primary.withOpacity(0.1),
                                            child: Text(
                                              (review['userName'] ?? 'U')[0].toUpperCase(),
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  review['userName'] ?? 'Khách hàng',
                                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                                Text(
                                                  (review['createdAt'] as Timestamp?)?.toDate().toString().substring(0, 16) ?? '',
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildStarRow(rating),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        review['comment'] ?? '',
                                        style: const TextStyle(fontSize: 15, height: 1.5),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Nút viết đánh giá
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text(
                        'Viết đánh giá của bạn',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => _showReviewDialog(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ==================== NÚT THÊM VÀO GIỎ (đã fix) ====================
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        if (selectedSize == null || selectedColor == null) {
                          Get.snackbar('Lỗi', 'Vui lòng chọn Size và Màu sắc');
                          return;
                        }

                        final item = CartItem(
                          product: widget.product,
                          size: selectedSize!,
                          color: selectedColor!,
                        );
                        cartController.addToCart(item);
                      },
                      child: const Text(
                        'Thêm vào giỏ hàng',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
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

  // Các hàm cũ giữ nguyên
  Widget _buildNoReviewSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Chưa có đánh giá nào',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy là người đầu tiên chia sẻ cảm nhận về sản phẩm này!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(double avgRating, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            avgRating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStarRow(avgRating, size: 28),
              const SizedBox(height: 4),
              Text(
                '$count đánh giá',
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow(double rating, {double size = 20}) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating ? Icons.star_half : Icons.star_border),
          color: Colors.amber[700],
          size: size,
        );
      }),
    );
  }

  void _showReviewDialog(BuildContext context) {
    // (giữ nguyên toàn bộ hàm dialog viết đánh giá như cũ)
    double selectedRating = 5.0;
    final TextEditingController commentController = TextEditingController();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            title: const Text('Viết đánh giá', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Bạn cảm thấy sản phẩm thế nào?', style: TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 20),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final bool isFilled = index < selectedRating;
                      return IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        icon: Icon(
                          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isFilled ? Colors.amber[700] : Colors.grey[400],
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() => selectedRating = index + 1.0);
                        },
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Chia sẻ cảm nhận của bạn...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontSize: 16))),
              ElevatedButton(
                onPressed: () async {
                  if (commentController.text.trim().isEmpty) {
                    Get.snackbar('Lỗi', 'Vui lòng nhập nhận xét');
                    return;
                  }
                  final user = Get.find<AuthController>().currentUser.value;
                  if (user == null) {
                    Get.snackbar('Lỗi', 'Vui lòng đăng nhập để đánh giá');
                    return;
                  }
                  await FirebaseFirestore.instance.collection('reviews').add({
                    'productId': widget.product.id,
                    'userId': user.uid,
                    'userName': user.name,
                    'rating': selectedRating,
                    'comment': commentController.text.trim(),
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Get.back();
                  Get.snackbar('Cảm ơn bạn!', 'Đánh giá đã được gửi thành công', backgroundColor: AppColors.primary, colorText: Colors.white);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                child: const Text('Gửi đánh giá', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
            actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          );
        },
      ),
    );
  }
}