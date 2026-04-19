import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: const Color(0xFFF4F7FE),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng quan cửa hàng',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1B3F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quản lý thông tin và doanh thu hệ thống',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 28),

            // ===== THỐNG KÊ SẢN PHẨM + ĐƠN HÀNG + DOANH THU =====
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, productSnap) {
                final productCount = productSnap.hasData ? productSnap.data!.docs.length : 0;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                  builder: (context, orderSnap) {
                    final orderCount = orderSnap.hasData ? orderSnap.data!.docs.length : 0;
                    double revenue = 0;
                    if (orderSnap.hasData) {
                      for (var doc in orderSnap.data!.docs) {
                        revenue += (doc['totalAmount'] as num?)?.toDouble() ?? 0;
                      }
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            _buildModernStatCard(
                              title: 'Sản phẩm',
                              value: productCount.toString(),
                              icon: Icons.inventory_2_rounded,
                              iconColor: const Color(0xFF4A90E2),
                              bgColor: const Color(0xFFE3F2FD),
                            ),
                            const SizedBox(width: 16),
                            _buildModernStatCard(
                              title: 'Đơn hàng',
                              value: orderCount.toString(),
                              icon: Icons.receipt_long_rounded,
                              iconColor: const Color(0xFFF57C00),
                              bgColor: const Color(0xFFFFF3E0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildRevenueCard(revenue),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            // ===== PHÂN TÍCH ĐÁNH GIÁ SẢN PHẨM =====
            const Text(
              'Phân tích đánh giá',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
              builder: (context, reviewSnap) {
                if (!reviewSnap.hasData) return const CircularProgressIndicator();

                final reviews = reviewSnap.data!.docs;
                if (reviews.isEmpty) {
                  return const Text('Chưa có đánh giá nào');
                }

                double totalRating = 0;
                Map<int, int> starCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

                for (var doc in reviews) {
                  int rating = (doc['rating'] ?? 0).toInt();
                  totalRating += rating;
                  if (starCount.containsKey(rating)) {
                    starCount[rating] = starCount[rating]! + 1;
                  }
                }

                final avgRating = totalRating / reviews.length;

                return Column(
                  children: [
                    Row(
                      children: [
                        _buildModernStatCard(
                          title: 'Tổng đánh giá',
                          value: reviews.length.toString(),
                          icon: Icons.rate_review,
                          iconColor: Colors.amber,
                          bgColor: const Color(0xFFFFF8E1),
                        ),
                        const SizedBox(width: 16),
                        _buildModernStatCard(
                          title: 'Điểm TB',
                          value: avgRating.toStringAsFixed(1),
                          icon: Icons.star,
                          iconColor: Colors.amber,
                          bgColor: const Color(0xFFFFF8E1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Phân bố sao
                    ...List.generate(5, (index) {
                      int star = 5 - index;
                      int count = starCount[star] ?? 0;
                      double percent = reviews.isNotEmpty ? (count / reviews.length) * 100 : 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text('$star★', style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percent / 100,
                                backgroundColor: Colors.grey[300],
                                color: Colors.amber,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('$count (${percent.toStringAsFixed(0)}%)'),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            Center(
              child: Text(
                'Chúc bạn quản trị vui vẻ! 🎉',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(double revenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF11998E).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng doanh thu',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${revenue.toStringAsFixed(0)}đ',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.attach_money_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}