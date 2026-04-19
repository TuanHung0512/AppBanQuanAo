import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashionstore/utils/constants.dart';
import 'package:get/get.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  static const List<String> statuses = [
    'Chờ thanh toán',
    'Đã thanh toán',
    'Đang giao',
    'Hoàn thành',
    'Hủy'
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final data = orders[index].data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  'Đơn #${orders[index].id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Khách: ${data['customerEmail'] ?? 'Không rõ'}'),
                    Text('Tổng: ${data['totalAmount']?.toStringAsFixed(0) ?? 0}đ'),
                    if (createdAt != null)
                      Text('Ngày: ${createdAt.day}/${createdAt.month}/${createdAt.year}'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  initialValue: data['status'],
                  onSelected: (value) async {
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orders[index].id)
                        .update({'status': value});
                    Get.snackbar('Thành công', 'Đã cập nhật trạng thái');
                  },
                  itemBuilder: (context) => statuses
                      .map((s) => PopupMenuItem(value: s, child: Text(s)))
                      .toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}