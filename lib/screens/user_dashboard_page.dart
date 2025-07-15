import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/bloc/auth_bloc.dart';
import 'package:thriftin_app/bloc/auth_event.dart';
import 'package:thriftin_app/bloc/auth_state.dart';
import 'package:thriftin_app/screens/login_page.dart';
import 'package:thriftin_app/screens/company_profile_page.dart';
import 'package:thriftin_app/screens/Product/all_product_page.dart';
import 'package:thriftin_app/screens/Product/produk_list_page.dart';
import 'package:thriftin_app/screens/Product/product_detail_page.dart';
import 'package:thriftin_app/screens/transaksi/cart_page_screen.dart';
import 'package:thriftin_app/Produk/bloc/product_bloc.dart';
import 'package:thriftin_app/Produk/bloc/product_event.dart';
import 'package:thriftin_app/Produk/bloc/product_state.dart';
import 'package:thriftin_app/screens/profile_page.dart';
import 'package:thriftin_app/services/auth_service.dart';
import 'package:thriftin_app/services/buy_service.dart';
import 'package:thriftin_app/transaksi/bloc/buy_bloc.dart';
import 'package:thriftin_app/transaksi/bloc/buy_event.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePageUser(),
      const Center(child: Text("Favorites")),
      const AllProductsPage(),
      BlocProvider(
        create: (_) => BuyBloc(BuyService())..add(FetchBuyHistory()),
        child: const CartPage(),
      ),
      const ProductListPage(),
    ];
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) =>  LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text("Thriftin'", style: TextStyle(color: Colors.black)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            )
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: Colors.grey, width: 0.2)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(Icons.home, "Home", 0),
              _buildNavIcon(Icons.favorite, "Favorites", 1),
              _buildNavIcon(Icons.store, "Store", 2),
              _buildNavIcon(Icons.shopping_cart, "Cart", 3),
              _buildNavIcon(Icons.history, "My Products", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isSelected ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class HomePageUser extends StatefulWidget {
  const HomePageUser({super.key});

  @override
  State<HomePageUser> createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  String? userName;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductAllFetched());
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final auth = AuthService();
      final user = await auth.getUser();
      setState(() {
        userName = user['name'];
      });
    } catch (_) {
      userName = "User";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Hello, Welcome 👋", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(
                          userName ?? "Loading...",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildCircularCompanies(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Recommendations for you", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            _buildProductList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularCompanies() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AuthService().getCompanies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Belum ada akun Company yang terdaftar."),
          );
        }

        return SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final company = snapshot.data![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CompanyProfilePage(
                        companyId: company['id'],
                        companyName: company['name'],
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.black,
                      child: const Icon(Icons.store, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 70,
                      child: Text(
                        company['name'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    return SizedBox(
      height: 280,
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.isSubmitting) return const Center(child: CircularProgressIndicator());

          final list = state.productList.take(5).toList();
          if (list.isEmpty) return const Center(child: Text("Tidak ada produk."));

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final product = list[index];
              final gambar = product['gambar'];
              final nama = product['nama_produk'] ?? '';
              final harga = product['harga'] ?? '0';

              return GestureDetector(
                onTap: () {
                  context.read<ProductBloc>().add(ProductSelected(product));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductDetailPage()),
                  );
                },
                child: Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        gambar != null
                            ? Image.network(
                                'http://10.0.2.2:8000/storage/$gambar',
                                height: double.infinity,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: double.infinity,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image_not_supported),
                              ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black54,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Rp $harga",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
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
