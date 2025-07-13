import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/Produk/bloc/product_bloc.dart';
import 'package:thriftin_app/Produk/bloc/product_event.dart';
import 'package:thriftin_app/Produk/bloc/product_state.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductAllFetched());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Semua Produk")),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.isSubmitting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(child: Text("Error: ${state.errorMessage}"));
          }

          if (state.productList.isEmpty) {
            return const Center(child: Text("Belum ada produk tersedia."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.productList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (_, i) {
              final produk = state.productList[i];
              return _ProductCard(produk: produk);
            },
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> produk;

  const _ProductCard({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    final String nama = produk['nama_produk'] ?? 'Nama tidak ada';
    final String harga = produk['harga'].toString();
    final String? gambar = produk['gambar'];

    return InkWell(
      onTap: () {
        // Kirim produk terpilih ke BLoC
        context.read<ProductBloc>().add(ProductSelected(produk));
        // Navigasi ke detail page
        Navigator.pushNamed(context, '/product-detail');
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: gambar != null
                      ? Image.network(
                          'http://10.0.2.2:8000/storage/$gambar',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.red.shade100,
                            child: const Icon(Icons.broken_image),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nama,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Rp $harga", style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}