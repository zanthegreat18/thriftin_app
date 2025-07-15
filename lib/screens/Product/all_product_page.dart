import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:thriftin_app/Produk/bloc/product_bloc.dart';
import 'package:thriftin_app/Produk/bloc/product_event.dart';
import 'package:thriftin_app/Produk/bloc/product_state.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductAllFetched());
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => _onSearchChanged(),
          decoration: InputDecoration(
            hintText: 'Cari produk...',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    ),
    body: BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.isSubmitting) return const Center(child: CircularProgressIndicator());

        if (state.errorMessage != null) {
          return Center(child: Text("Error: ${state.errorMessage}"));
        }

        final filteredList = state.productList.where((produk) {
          final nama = (produk['nama_produk'] ?? '').toString().toLowerCase();
          return nama.contains(_searchQuery);
        }).toList();

        if (filteredList.isEmpty) {
          return const Center(child: Text("Tidak ada produk ditemukan."));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (_, i) {
            final produk = filteredList[i];
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
        context.read<ProductBloc>().add(ProductSelected(produk));
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
                      ? CachedNetworkImage(
                          imageUrl: 'http://10.0.2.2:8000/storage/$gambar',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(
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
