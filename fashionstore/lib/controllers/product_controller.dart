import 'package:get/get.dart';
import 'package:fashionstore/models/product_model.dart';
import 'package:fashionstore/services/firebase_service.dart';

class ProductController extends GetxController {
  final FirebaseService _service = FirebaseService();

  RxList<Product> products = <Product>[].obs;
  RxBool isLoading = true.obs; // Thêm trạng thái loading

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts() {
    isLoading.value = true;
    // Lắng nghe dữ liệu từ Firebase
    _service.getProducts().listen(
          (data) {
        products.value = data;
        isLoading.value = false; // Tắt loading khi đã lấy xong dữ liệu (dù có hay không có sản phẩm)
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar('Lỗi tải dữ liệu', error.toString());
      },
    );
  }

  // Hàm hỗ trợ gọi dữ liệu mẫu từ UI
  Future<void> addSampleData() async {
    isLoading.value = true;
    await _service.addSampleProducts();
    Get.snackbar('Thành công', 'Đã thêm dữ liệu mẫu lên Firestore!');
    // Dữ liệu sẽ tự động cập nhật vào danh sách nhờ Stream
  }
}