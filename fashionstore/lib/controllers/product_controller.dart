import 'package:get/get.dart';
import 'package:fashionstore/models/product_model.dart';
import 'package:fashionstore/services/firebase_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class ProductController extends GetxController {
  final FirebaseService _service = FirebaseService();

  RxList<Product> products = <Product>[].obs;
  RxBool isLoading = true.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  // Tìm kiếm & lọc danh mục
  RxString searchQuery = ''.obs;
  RxString selectedCategory = 'Tất cả'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts() {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    // Timeout 5 giây
    final timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (isLoading.value) {
        isLoading.value = false;
        hasError.value = true;
        errorMessage.value = 'Tải sản phẩm quá lâu. Kiểm tra mạng và thử lại.';
      }
    });

    _service.getProducts().listen(
          (data) {
        timeoutTimer.cancel(); // Hủy timeout khi có dữ liệu
        products.value = data;
        isLoading.value = false;
        hasError.value = false;
      },
      onError: (error) {
        timeoutTimer.cancel();
        isLoading.value = false;
        hasError.value = true;
        errorMessage.value = error.toString();
        Get.snackbar('Lỗi tải dữ liệu', error.toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      },
    );
  }

  // Retry thủ công
  void retryFetch() {
    fetchProducts();
  }

  Future<void> addSampleData() async {
    isLoading.value = true;
    hasError.value = false;
    await _service.addSampleProducts();
    Get.snackbar('Thành công', 'Đã thêm dữ liệu mẫu lên Firestore!',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  // Danh mục
  List<String> get categories {
    final cats = products.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['Tất cả', ...cats];
  }

  // Sản phẩm đã lọc (search + category)
  List<Product> get filteredProducts {
    return products.where((product) {
      final matchesSearch = searchQuery.value.isEmpty ||
          product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          product.description.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesCategory = selectedCategory.value == 'Tất cả' ||
          product.category == selectedCategory.value;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = 'Tất cả';
  }
}