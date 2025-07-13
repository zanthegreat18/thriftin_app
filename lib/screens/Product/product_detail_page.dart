import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/Produk/bloc/product_bloc.dart';
import 'package:thriftin_app/Produk/bloc/product_state.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductBloc>().state.selectedProduct;

    if (product == null || product.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Tidak ada data produk")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Gambar Produk
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Image.network(
                    'http://10.0.2.2:8000/storage/${product['gambar']}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.broken_image, size: 60)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // Info Produk
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    // Harga
                    Text(
                      "Rp ${product['harga']}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Deskripsi Produk
                    Text(
                      product['deskripsi'] ?? '-',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Lokasi Produk
                    if (product['lat'] != null &&
                        product['lng'] != null &&
                        product['lat'].toString().isNotEmpty &&
                        product['lng'].toString().isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Lokasi Produk",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                "(${double.parse(product['lat'].toString()).toStringAsFixed(4)}, "
                                "${double.parse(product['lng'].toString()).toStringAsFixed(4)})",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      )
                    else
                      const Text(
                        "Lokasi tidak tersedia",
                        style: TextStyle(color: Colors.grey),
                      ),

                    // Variasi dummy
                    const Text("Variations",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _variationBox("Pink"),
                        const SizedBox(width: 8),
                        _variationBox("M"),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Gambar variasi dummy
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(
                          3,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(
                                  'http://10.0.2.2:8000/storage/${product['gambar']}',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol bawah
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text("Add to cart"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {},
                      child: const Text("Buy now"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _variationBox(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label),
    );
  }
}