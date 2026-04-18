import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashionstore/models/cart_item_model.dart';
import 'package:fashionstore/screens/invoice_screen.dart';

class CartController extends GetxController {
  RxList<CartItem> cartItems = <CartItem>[].obs;
  RxBool isProcessing = false.obs;

  void addToCart(CartItem item) {
    var existing = cartItems.firstWhereOrNull((i) =>
    i.product.id == item.product.id && i.size == item.size && i.color == item.color);

    if (existing != null) {
      existing.quantity++;
      cartItems.refresh();
    } else {
      cartItems.add(item);
    }
    Get.snackbar('Thành công', 'Đã thêm vào giỏ hàng');
  }

  double get totalPrice => cartItems.fold(0, (sum, item) => sum + item.total);

  Future<void> checkout() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar('Lỗi', 'Vui lòng đăng nhập để thực hiện thanh toán!');
      return;
    }

    if (cartItems.isEmpty) return;

    try {
      isProcessing.value = true;

      final itemsMap = cartItems.map((item) => {
        'productId': item.product.id,
        'name': item.product.name,
        'size': item.size,
        'color': item.color,
        'price': item.product.price,
        'quantity': item.quantity,
      }).toList();

      final docRef = await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'customerEmail': user.email,
        'items': itemsMap,
        'totalAmount': totalPrice,
        'status': 'Chờ thanh toán',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final double finalTotal = totalPrice;

      cartItems.clear();
      isProcessing.value = false;

      Get.off(() => InvoiceScreen(
        orderId: docRef.id,
        totalAmount: finalTotal,
      ));

    } catch (e) {
      isProcessing.value = false;
      Get.snackbar('Lỗi thanh toán', 'Có lỗi xảy ra: ${e.toString()}');
    }
  }
}