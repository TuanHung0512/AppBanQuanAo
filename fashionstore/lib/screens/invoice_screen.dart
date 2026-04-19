import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/utils/constants.dart';
import 'package:fashionstore/screens/main_screen.dart';

class InvoiceScreen extends StatelessWidget {
  final String orderId;
  final double totalAmount;

  const InvoiceScreen({super.key, required this.orderId, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    const String bankBin = '970436';
    const String bankAccount = '1028805664';
    const String accountName = 'VUONG TUAN HUNG';

    final String shortOrderId = orderId.substring(0, 6).toUpperCase();
    final String addInfo = 'Thanh toan don $shortOrderId';

    final String qrImageUrl = 'https://img.vietqr.io/image/$bankBin-$bankAccount-compact2.png'
        '?amount=${totalAmount.toInt()}'
        '&addInfo=${Uri.encodeComponent(addInfo)}'
        '&accountName=${Uri.encodeComponent(accountName)}';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Hóa Đơn Thanh Toán'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                const Text('Tạo Đơn Hàng Thành Công!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Mã đơn: $orderId', style: const TextStyle(color: Colors.grey)),
                const Divider(height: 40, thickness: 1, color: Colors.black12),

                const Text('Quét mã QR để thanh toán', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.network(
                    qrImageUrl,
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(width: 250, height: 250, child: Center(child: CircularProgressIndicator()));
                    },
                    errorBuilder: (context, error, stackTrace) => const SizedBox(
                      width: 250, height: 250, child: Center(child: Text('Lỗi tải mã QR', style: TextStyle(color: Colors.red))),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng thanh toán:', style: TextStyle(fontSize: 16)),
                    Text('${totalAmount.toStringAsFixed(0)}đ', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Nội dung CK: $addInfo', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Get.offAll(() => MainScreen()),   // Quay về MainScreen có bottom bar
                    child: const Text('Hoàn tất & Về Trang Chủ', style: TextStyle(fontSize: 16, color: AppColors.primary)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}