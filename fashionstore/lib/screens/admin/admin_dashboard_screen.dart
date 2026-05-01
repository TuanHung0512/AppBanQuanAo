import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

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

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products')
                  .snapshots(),
              builder: (context, productSnap) {
                final productCount = productSnap.hasData ? productSnap.data!
                    .docs.length : 0;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('orders')
                      .snapshots(),
                  builder: (context, orderSnap) {
                    final orderCount = orderSnap.hasData ? orderSnap.data!.docs
                        .length : 0;
                    double revenue = 0;
                    if (orderSnap.hasData) {
                      for (var doc in orderSnap.data!.docs) {
                        revenue +=
                            (doc['totalAmount'] as num?)?.toDouble() ?? 0;
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

            Center(
              child: ElevatedButton(
                onPressed: _exportToExcel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF11998E),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: const Text(
                  'Xuất doanh thu ra Excel (CSV)',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Sản phẩm bán chạy nhất',
              style: TextStyle(fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1B3F)),
            ),
            const SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders')
                  .snapshots(),
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
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8)
                      ],
                    ),
                    child: const Center(
                        child: Text('Chưa có đơn hàng nào để phân tích')),
                  );
                }

                Map<String, int> productSales = {};
                for (var doc in orders) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status']?.toString() ?? '';

                  if (status != 'Đã thanh toán' && status != 'Hoàn thành') {
                    continue;
                  }

                  final items = data['items'] as List<dynamic>? ?? [];
                  for (var item in items) {
                    if (item is Map) {
                      final name = item['name'] as String? ??
                          'Sản phẩm không rõ';
                      final qty = (item['quantity'] as num?)?.toInt() ?? 0;
                      productSales[name] = (productSales[name] ?? 0) + qty;
                    }
                  }
                }

                final sorted = productSales.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final top5 = sorted.take(5).toList();

                if (top5.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Text(
                        'Chưa có đơn hàng nào đã thanh toán/hoàn thành')),
                  );
                }

                return Column(
                  children: top5
                      .asMap()
                      .entries
                      .map((entry) {
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
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
                                color: rank <= 3 ? Colors.white : Colors
                                    .black87,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          productName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
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

            const Text(
              'Phân tích đánh giá',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reviews')
                  .snapshots(),
              builder: (context, reviewSnap) {
                if (!reviewSnap.hasData)
                  return const CircularProgressIndicator();

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

                    ...List.generate(5, (index) {
                      int star = 5 - index;
                      int count = starCount[star] ?? 0;
                      double percent = reviews.isNotEmpty ? (count /
                          reviews.length) * 100 : 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                                '$star★', style: const TextStyle(fontSize: 16)),
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
                'Chào mừng VTH quay trở lại! 🎉',
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

  Future<void> _exportToExcel() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar('Thông báo', 'Chưa có đơn hàng nào để xuất!', backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      final excel = Excel.createExcel();
      final Sheet sheet = excel['DoanhThu'];
      double totalRevenue = 0;

      sheet.appendRow([
        TextCellValue('Mã đơn hàng'),
        TextCellValue('Khách hàng'),
        TextCellValue('Tổng tiền'),
        TextCellValue('Trạng thái'),
        TextCellValue('Ngày tạo'),
      ]);

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final orderId = doc.id;
        final customer = (data['customerEmail'] ?? 'Không rõ').toString();
        final total = (data['totalAmount'] as num?)?.toDouble() ?? 0;
        final status = (data['status'] ?? 'Chờ thanh toán').toString();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

        totalRevenue += total;

        final dateStr = createdAt != null
            ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}'
            : '';

        sheet.appendRow([
          TextCellValue(orderId),
          TextCellValue(customer),
          DoubleCellValue(total),
          TextCellValue(status),
          TextCellValue(dateStr),
        ]);
      }

      sheet.appendRow([]);

      sheet.appendRow([
        TextCellValue('TỔNG DOANH THU'),
        TextCellValue(''),
        DoubleCellValue(totalRevenue),
      ]);

      sheet.setColumnWidth(0, 25);
      sheet.setColumnWidth(1, 30);
      sheet.setColumnWidth(2, 18);
      sheet.setColumnWidth(3, 20);
      sheet.setColumnWidth(4, 18);

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'bao_cao_doanh_thu_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '${directory.path}/$fileName';

      final fileBytes = excel.encode();

      if (fileBytes == null) {
        throw Exception('Không thể tạo file Excel');
      }

      final file = File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      Get.snackbar(
        '✅ Thành công',
        'Đã tạo file Excel!',
        backgroundColor: const Color(0xFF11998E),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.description, color: Color(0xFF11998E), size: 70),
                const SizedBox(height: 16),

                const Text(
                  'Xuất Excel thành công!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Text(
                  fileName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Share.shareXFiles([XFile(file.path)], text: 'Báo cáo doanh thu');
                    },
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text(
                      'Chia sẻ / Tải file',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF11998E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xuất Excel: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}