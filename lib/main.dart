import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/Produk/bloc/product_bloc.dart';
import 'package:thriftin_app/bloc/auth_bloc.dart';
import 'package:thriftin_app/screens/login_page.dart';
import 'package:thriftin_app/screens/Product/product_detail_page.dart';
import 'package:thriftin_app/screens/admin_dashboard_page.dart';
import 'package:thriftin_app/screens/user_dashboard_page.dart';
import 'package:thriftin_app/services/auth_service.dart';
import 'package:thriftin_app/services/product_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> deleteOldProductDB() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'product.db');
  await deleteDatabase(path);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await deleteOldProductDB(); // 🧹 delete DB lama biar gak error user_id
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final productService = ProductService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authService)),
        BlocProvider(create: (_) => ProductBloc(productService)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Thriftin App',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFFBF9FC),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.black,
            secondary: Colors.blueAccent,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => LoginPage(),
          '/admin-dashboard': (_) => AdminDashboardPage(),
          '/user-dashboard': (_) => const UserDashboardPage(),
          '/product-detail': (_) => const ProductDetailPage(),
          '/product-detail': (_) => const ProductDetailPage(),
        },
      ),
    );
  }
}