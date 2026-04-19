import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/controllers/product_controller.dart';
import 'package:fashionstore/widgets/product_card.dart';
import 'package:fashionstore/utils/constants.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductController productController = Get.find<ProductController>();
  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  final List<String> _banners = [
    'https://picsum.photos/id/1015/800/400',
    'https://picsum.photos/id/133/800/400',
    'https://picsum.photos/id/201/800/400',
    'https://picsum.photos/id/251/800/400',
    'https://picsum.photos/id/1005/800/400',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => productController.retryFetch(),
      color: AppColors.primary,
      child: Obx(() {
        // ==================== LOADING STATE ====================
        if (productController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 24),
                const Text('Đang tải sản phẩm...', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: productController.addSampleData,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Tạo Dữ Liệu Mẫu', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: productController.retryFetch,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // ==================== ERROR STATE ====================
        if (productController.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(productController.errorMessage.value, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: productController.retryFetch,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: productController.addSampleData,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo Dữ Liệu Mẫu'),
                ),
              ],
            ),
          );
        }

        // ==================== MAIN UI ====================
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // BANNER AUTO SLIDER
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _banners.length,
                  onPageChanged: (index) => _currentPage = index,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(_banners[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(16),
                        child: const Text(
                          'Sale Hot\nGiảm đến 50%',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Ô TÌM KIẾM
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (value) => productController.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),

              // DANH MỤC
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: productController.categories.length,
                  itemBuilder: (context, index) {
                    final cat = productController.categories[index];
                    final isSelected = cat == productController.selectedCategory.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        onSelected: (_) {
                          productController.selectedCategory.value = cat;
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // GRID SẢN PHẨM
              if (productController.filteredProducts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('Không tìm thấy sản phẩm nào', style: TextStyle(fontSize: 16, color: Colors.grey)),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.52,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: productController.filteredProducts.length,
                    itemBuilder: (context, index) => ProductCard(
                      product: productController.filteredProducts[index],
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}