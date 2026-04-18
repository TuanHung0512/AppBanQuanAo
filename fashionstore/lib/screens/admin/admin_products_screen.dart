import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fashionstore/models/product_model.dart';
import 'package:fashionstore/utils/constants.dart';
import 'package:get/get.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  Future<String?> _uploadImageToFirebase(File? imageFile) async {
    if (imageFile == null) return null;
    try {
      String fileName = 'products/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Lỗi Upload', 'Không thể tải ảnh lên: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return null;
    }
  }

  void _showProductForm([Product? product]) {
    final nameCtrl = TextEditingController(text: product?.name);
    final priceCtrl = TextEditingController(text: product?.price.toString());
    final descCtrl = TextEditingController(text: product?.description);
    final imageCtrl = TextEditingController(text: product?.imageUrl);
    final categoryCtrl = TextEditingController(text: product?.category);

    File? selectedImage;
    bool isUploading = false;

    // THAY Get.defaultDialog BẰNG Get.dialog VÀ CUSTOM LẠI TỪ ĐẦU ĐỂ BỎ MÀU VÀNG
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        product == null ? 'Thêm Sản Phẩm' : 'Sửa Sản Phẩm',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3F)),
                      ),
                    ),
                    const Divider(height: 30),

                    // Các ô nhập liệu được làm mới với border góc cạnh
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Tên sản phẩm',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Giá',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: categoryCtrl,
                      decoration: InputDecoration(
                        labelText: 'Danh mục',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ảnh xem trước
                    if (selectedImage != null)
                      Center(
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover),
                          ),
                        ),
                      )
                    else if (imageCtrl.text.isNotEmpty)
                      Center(
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(image: NetworkImage(imageCtrl.text), fit: BoxFit.cover),
                          ),
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        label: const Text('Chọn ảnh từ máy', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800], // Màu nút xám đen sang trọng
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              selectedImage = File(pickedFile.path);
                              imageCtrl.clear();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imageCtrl,
                      decoration: InputDecoration(
                        labelText: 'Hoặc dán URL ảnh',
                        hintText: 'https://...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty) setState(() => selectedImage = null);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Nút Hành động (Hủy & Xác nhận)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Hủy', style: TextStyle(color: Colors.black54)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isUploading ? null : () async {
                              setState(() => isUploading = true);

                              String finalImageUrl = imageCtrl.text.isNotEmpty ? imageCtrl.text : 'https://picsum.photos/800';

                              if (selectedImage != null) {
                                String? uploadedUrl = await _uploadImageToFirebase(selectedImage);
                                if (uploadedUrl != null) {
                                  finalImageUrl = uploadedUrl;
                                } else {
                                  setState(() => isUploading = false);
                                  return;
                                }
                              }

                              final data = {
                                'name': nameCtrl.text.trim(),
                                'price': double.tryParse(priceCtrl.text) ?? 0,
                                'description': descCtrl.text.trim(),
                                'imageUrl': finalImageUrl,
                                'category': categoryCtrl.text.trim().isEmpty ? 'Khác' : categoryCtrl.text.trim(),
                                'sizes': ['S', 'M', 'L', 'XL'],
                                'colors': ['Đen', 'Trắng', 'Xám'],
                              };

                              try {
                                if (product == null) {
                                  await FirebaseFirestore.instance.collection('products').add(data);
                                } else {
                                  await FirebaseFirestore.instance.collection('products').doc(product.id).update(data);
                                }
                                Get.back(); // Đóng dialog
                                Get.snackbar('Thành công', product == null ? 'Đã thêm sản phẩm' : 'Đã cập nhật', backgroundColor: Colors.green, colorText: Colors.white);
                              } catch (e) {
                                Get.snackbar('Lỗi', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
                                setState(() => isUploading = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isUploading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(product == null ? 'Thêm' : 'Cập nhật', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: () => _showProductForm(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final products = snapshot.data!.docs
              .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(p.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported))),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${p.category} • ${p.price.toStringAsFixed(0)}đ'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _showProductForm(p)
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          // Dialog Xóa cũng bỏ màu vàng mặc định
                          Get.dialog(
                              Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Xóa sản phẩm?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 12),
                                      const Text('Bạn có chắc muốn xóa không?'),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: OutlinedButton(
                                                  onPressed: ()=>Get.back(),
                                                  child: const Text('Hủy')
                                              )
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                                onPressed: () async {
                                                  await FirebaseFirestore.instance.collection('products').doc(p.id).delete();
                                                  Get.back();
                                                },
                                                child: const Text('Xóa', style: TextStyle(color: Colors.white))
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}