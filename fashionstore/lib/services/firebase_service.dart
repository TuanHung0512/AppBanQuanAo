import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Đảm bảo đường dẫn import này đúng với cấu trúc thư mục của bạn
import 'package:fashionstore/models/product_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy danh sách sản phẩm theo thời gian thực (Real-time)
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc.data(), doc.id)).toList());
  }

  // Hàm thêm dữ liệu mẫu lên Firestore (Chỉ nên gọi 1 lần khi khởi tạo dữ liệu)
  Future<void> addSampleProducts() async {
    // Danh sách sản phẩm với Link ảnh thật (chuyên về thời trang)
    final products = [
      Product(
          id: '',
          name: 'Áo Thun Oversize Trắng',
          description: 'Chất cotton 100% thoáng mát, form rộng rãi thoải mái, phù hợp mặc hàng ngày.',
          price: 250000,
          imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
          category: 'Áo',
          sizes: ['S', 'M', 'L', 'XL'],
          colors: ['Trắng', 'Đen', 'Xám']
      ),
      Product(
          id: '',
          name: 'Quần Jeans Nam Cổ Điển',
          description: 'Phong cách streetwear cá tính, chất liệu denim cao cấp không phai màu.',
          price: 499000,
          imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=800&q=80',
          category: 'Quần',
          sizes: ['28', '30', '32', '34'],
          colors: ['Xanh Nhạt', 'Xanh Đậm', 'Đen']
      ),
      Product(
          id: '',
          name: 'Đầm Hoa Cúc Mùa Hè',
          description: 'Đầm voan nhẹ nhàng, thướt tha. Phù hợp cho những chuyến đi biển hoặc dạo phố.',
          price: 350000,
          imageUrl: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=format&fit=crop&w=800&q=80',
          category: 'Váy',
          sizes: ['S', 'M', 'L'],
          colors: ['Vàng', 'Trắng Hoa']
      ),
      Product(
          id: '',
          name: 'Áo Khoác Denim Bụi Bặm',
          description: 'Áo khoác ngoài cực chất, dễ dàng phối với áo thun basic bên trong.',
          price: 550000,
          imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=800&q=80',
          category: 'Áo Khoác',
          sizes: ['M', 'L', 'XL'],
          colors: ['Xanh Denim']
      ),
      Product(
          id: '',
          name: 'Sơ Mi Nam Công Sở',
          description: 'Chất liệu chống nhăn, form dáng ôm vừa phải, mang lại vẻ lịch lãm cho phái mạnh.',
          price: 320000,
          imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&w=800&q=80',
          category: 'Áo',
          sizes: ['S', 'M', 'L', 'XL', 'XXL'],
          colors: ['Trắng', 'Xanh Biển', 'Đen']
      ),
    ];

    try {
      final batch = _firestore.batch();
      final collectionRef = _firestore.collection('products');

      // Sử dụng batch để đẩy nhiều dữ liệu lên cùng một lúc nhanh chóng và an toàn hơn
      for (var p in products) {
        final docRef = collectionRef.doc(); // Tự động tạo ID mới
        batch.set(docRef, {
          'name': p.name,
          'description': p.description,
          'price': p.price,
          'imageUrl': p.imageUrl,
          'category': p.category,
          'sizes': p.sizes,
          'colors': p.colors,
          'createdAt': FieldValue.serverTimestamp(), // Thêm thời gian tạo để dễ sắp xếp
        });
      }

      await batch.commit();
      print("Đã thêm thành công dữ liệu mẫu lên Firestore!");

    } catch (e) {
      print("Lỗi khi thêm dữ liệu mẫu: $e");
    }
  }
}