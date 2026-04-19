import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fashionstore/controllers/auth_controller.dart';
import 'package:fashionstore/controllers/product_controller.dart';
import 'package:fashionstore/controllers/cart_controller.dart';
import 'package:fashionstore/screens/login_screen.dart';
import 'package:fashionstore/screens/auth/register_screen.dart';
import 'package:fashionstore/screens/home_screen.dart';
import 'package:fashionstore/utils/constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Khởi tạo các Controller (permanent: true để không bị xóa khi chuyển màn hình)
  Get.put(AuthController(), permanent: true);
  Get.put(ProductController(), permanent: true);
  Get.put(CartController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FashionStore - Bán Quần Áo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        primaryColor: AppColors.primary,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/login',           
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
      ],
    );
  }
}