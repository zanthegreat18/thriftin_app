import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/Produk/bloc/product_bloc.dart';
import 'package:thriftin_app/Produk/bloc/product_event.dart';
import 'package:thriftin_app/Produk/bloc/product_state.dart';
import 'upload_product_page.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductFetched());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Produk Thrift",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Cari produk...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF0F1F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadProductPage()),
              ).then((_) {
                context.read<ProductBloc>().add(ProductFetched());
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.isSubmitting) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.errorMessage != null) {
            return Center(child: Text("Error: ${state.errorMessage}"));
          } else if (state.productList.isEmpty) {
            return const Center(child: Text("Belum ada produk."));
          }

          final displayList = _searchQuery.isEmpty
              ? state.productList
              : state.productList
                  .where((product) => product['nama_produk']
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: displayList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final product = displayList[index];
                return _buildProductCard(product);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            context.read<ProductBloc>().add(ProductSelected(product));
            await Future.delayed(const Duration(milliseconds: 100));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductDetailPage()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FA),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(16)),
                        image: product['gambar'] != null
                            ? DecorationImage(
                                image: NetworkImage(
                                    'http://10.0.2.2:8000/storage/${product['gambar']}'),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: product['gambar'] == null
                          ? const Center(
                              child: Icon(Icons.image_not_supported, size: 40),
                            )
                          : null,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black54),
                        onPressed: () {
                          context
                              .read<ProductBloc>()
                              .add(ProductDeleted(product['id']));
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['nama_produk'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Rp ${product['harga']}",
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.info,
                        size: 18, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
