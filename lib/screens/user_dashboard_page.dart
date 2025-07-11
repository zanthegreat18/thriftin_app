import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/bloc/auth_bloc.dart';
import 'package:thriftin_app/bloc/auth_event.dart';
import 'package:thriftin_app/bloc/auth_state.dart';
import 'package:thriftin_app/screens/login_page.dart';
import 'package:thriftin_app/screens/produk_list_page.dart';


class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePageUser(), // halaman utama
    const Center(child: Text("Favorites")),
    const ProductListPage(), // halaman store
    const Center(child: Text("Cart")),
    const Center(child: Text("History")),
  ];

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
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTap,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
            BottomNavigationBarItem(icon: Icon(Icons.store_mall_directory), label: "Store"),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          ],
        ),
      ),
    );
  }
}

class HomePageUser extends StatelessWidget {
  const HomePageUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const TextField(
          decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: Icon(Icons.search),
            filled: true,
            fillColor: Color(0xFFF0F1F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 0),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.brown.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Up to 75% DISCOUNT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      )),
                  SizedBox(height: 8),
                  Text("STARTS MIDNIGHT 11 OCTOBER",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Recommendations for you",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (_, index) => _ProductCard(index: index),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final int index;

  const _ProductCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final names = ["Cozy Chair", "Grandpa Chair", "Vintage Lamp", "Coffee Table"];
    final prices = [55.00, 65.00, 30.00, 120.00];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Icon(Icons.chair, size: 40)),
              ),
            ),
            const SizedBox(height: 8),
            Text(names[index], style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("\$${prices[index]}", style: const TextStyle(color: Colors.black54)),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
