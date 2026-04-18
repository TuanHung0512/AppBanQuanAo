import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fashionstore/utils/constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bọc bằng SingleChildScrollView để chống tràn viền (Overflow)
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
                    color: Color(0xFF0B1B3F)
                )
            ),
            const SizedBox(height: 8),
            Text(
              'Quản lý thông tin và doanh thu hệ thống',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 28),

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
            const SizedBox(height: 40), // Thay Spacer bằng SizedBox cố định
            Center(
              child: Text(
                'Chúc bạn quản trị vui vẻ! 🎉',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 20), // Thêm chút khoảng trống phía dưới cùng
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
                    fontWeight: FontWeight.w500
                )
            ),
            const SizedBox(height: 4),
            Text(
                value,
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: iconColor
                )
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
                      fontWeight: FontWeight.w500
                  )
              ),
              const SizedBox(height: 8),
              Text(
                  '${revenue.toStringAsFixed(0)}đ',
                  style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  )
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
                size: 40
            ),
          )
        ],
      ),
    );
  }
}