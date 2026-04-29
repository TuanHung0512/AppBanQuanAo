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
    'https://scontent.fhan9-1.fna.fbcdn.net/v/t39.30808-6/550305934_1383829357077943_1870842637479551856_n.jpg?stp=dst-jpg_s960x960_tt6&_nc_cat=109&ccb=1-7&_nc_sid=2a1932&_nc_eui2=AeHM6OL3EdH6CAQuiJD7zUlQFIDehR0TyTIUgN6FHRPJMt4o3I8vNmjvCV0iLI0QwxD4ruZKV_22MOXDR-pgj6WY&_nc_ohc=u6fdpRJMZZsQ7kNvwHS2vQO&_nc_oc=AdrImoAcLzqktCilao2_cTwxH6YbwRSlAtW_NeNQA4gAquTmjtC9vMCsKZBGzp5PpFQ&_nc_zt=23&_nc_ht=scontent.fhan9-1.fna&_nc_gid=10I_6Bf-O6wU6YzZ94c4iA&_nc_ss=7b2a8&oh=00_Af3P-s-3Q2PbKKWXtMPiLorIb87fjXzyccCSWgBumeMVLQ&oe=69F69C49',
    'https://wallpaperaccess.com/full/4599521.jpg',
    'https://i.pinimg.com/736x/98/83/79/988379d4acd3d5338ed345d0b4ec009d.jpg',
    'https://i.mdel.net/mdx/i/2011/09/P9295123-1280w-sfw-1024x697.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentPage = (_currentPage + 1) % _banners.length;
      _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
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
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: RefreshIndicator(
        onRefresh: () async => productController.retryFetch(),
        color: AppColors.primary,
        child: Obx(() {

          if (productController.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 28),
                  const Text(
                    'Đang tải sản phẩm...',
                    style: TextStyle(color: Colors.white70, fontSize: 15, letterSpacing: 1, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: productController.addSampleData,
                        icon: const Icon(Icons.auto_awesome, color: Colors.white),
                        label: const Text('Tạo dữ liệu mẫu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),

                      const SizedBox(width: 12),

                      OutlinedButton.icon(
                        onPressed: productController.retryFetch,
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        label: const Text('Thử lại', style: TextStyle(color: Colors.white70)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.15)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          if (productController.hasError.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 85, color: AppColors.primary.withOpacity(0.7)),
                    const SizedBox(height: 24),

                    Text(
                      productController.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      onPressed: productController.retryFetch,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Thử lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FASHION STORE',
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Thời trang cá tính • darkwear • high fashion',
                        style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _banners.length,
                    onPageChanged: (index) => _currentPage = index,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 25, spreadRadius: 2)],
                          image: DecorationImage(image: NetworkImage(_banners[index]), fit: BoxFit.cover),
                        ),

                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.88)],
                            ),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  'NEW\nCOLLECTION',
                                  style: TextStyle(color: Colors.white, fontSize: 30, height: 1.1, letterSpacing: 3, fontWeight: FontWeight.w900),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  'Táo bạo • bí ẩn • khác biệt',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7), letterSpacing: 1.5, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),

                    child: TextField(
                      onChanged: (value) => productController.searchQuery.value = value,
                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm sản phẩm...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: productController.categories.length,
                    itemBuilder: (context, index) {
                      final cat = productController.categories[index];
                      final isSelected = cat == productController.selectedCategory.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),

                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.black,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSelected ? AppColors.primary : Colors.white12),
                          ),

                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => productController.selectedCategory.value = cat,

                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'SẢN PHẨM NỔI BẬT',
                    style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2, fontWeight: FontWeight.w900),
                  ),
                ),

                const SizedBox(height: 18),

                if (productController.filteredProducts.isEmpty)

                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'Không tìm thấy sản phẩm nào',
                        style: TextStyle(color: Colors.white54, fontSize: 15),
                      ),
                    ),
                  )

                else

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.52,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),

                      itemCount: productController.filteredProducts.length,

                      itemBuilder: (context, index) {
                        return ProductCard(product: productController.filteredProducts[index]);
                      },
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          );
        }),
      ),
    );
  }
}