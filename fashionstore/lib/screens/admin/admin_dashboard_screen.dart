import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

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

            const SizedBox(height: 24),

            // ===== NÚT XUẤT EXCEL =====
            Center(
              child: ElevatedButton.icon(
                onPressed: _exportToCsv,
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text(
                  'Xuất doanh thu ra Excel (CSV)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF11998E),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ===== SẢN PHẨM BÁN CHẠY NHẤT =====
            const Text(
              'Sản phẩm bán chạy nhất',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3F)),
            ),
            const SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (context, orderSnap) {
                if (!orderSnap.hasData) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ));
                }

                final orders = orderSnap.data!.docs;
                if (orders.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    ),
                    child: const Center(child: Text('Chưa có đơn hàng nào để phân tích')),
                  );
                }

                // Tính sản phẩm bán chạy
                Map<String, int> productSales = {};
                for (var doc in orders) {
                  final items = (doc.data() as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
                  for (var item in items) {
                    if (item is Map) {
                      final name = item['name'] as String? ?? 'Sản phẩm không rõ';
                      final qty = (item['quantity'] as num?)?.toInt() ?? 0;
                      productSales[name] = (productSales[name] ?? 0) + qty;
                    }
                  }
                }

                final sorted = productSales.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final top5 = sorted.take(5).toList();

                if (top5.isEmpty) {
                  return const Text('Chưa có dữ liệu bán hàng');
                }

                return Column(
                  children: top5.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final productName = entry.value.key;
                    final sold = entry.value.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: rank == 1
                                ? const Color(0xFFFFD700)
                                : rank == 2
                                ? const Color(0xFFC0C0C0)
                                : rank == 3
                                ? const Color(0xFFCD7F32)
                                : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '#$rank',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: rank <= 3 ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          productName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF11998E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$sold lượt',
                            style: const TextStyle(
                              color: Color(0xFF11998E),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                'Chào mứng Vương Tuấn Hưng đã trở lại! 🎉',
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

  // ===== HÀM XUẤT CSV DOANH THU (Dán trực tiếp vào Excel) =====
  Future<void> _exportToCsv() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar(
          'Thông báo',
          'Chưa có đơn hàng nào để xuất!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final buffer = StringBuffer();
      buffer.writeln('Mã đơn hàng,Khách hàng,Tổng tiền (đ),Trạng thái,Ngày tạo');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final orderId = doc.id;
        final customer = (data['customerEmail'] ?? 'Không rõ').toString();
        final total = (data['totalAmount'] as num?)?.toDouble() ?? 0;
        final status = (data['status'] ?? 'Chờ thanh toán').toString();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final dateStr = createdAt != null
            ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}'
            : '';

        final safeCustomer = customer.replaceAll('"', '""');
        buffer.writeln('"$orderId","$safeCustomer",${total.toStringAsFixed(0)},"$status","$dateStr"');
      }

      final csvContent = buffer.toString();
      await Clipboard.setData(ClipboardData(text: csvContent));

      Get.snackbar(
        ' Đã copy thành công!',
        'Đã copy ${snapshot.docs.length} đơn hàng vào clipboard.\nMở Excel → Paste (Ctrl+V)',
        backgroundColor: const Color(0xFF11998E),
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.table_chart, color: Color(0xFF11998E), size: 28),
                    SizedBox(width: 12),
                    Text('Dữ liệu CSV đã sẵn sàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      csvContent.length > 550
                          ? csvContent.substring(0, 550) + '\n...(còn lại)'
                          : csvContent,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF11998E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Đóng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xuất: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}