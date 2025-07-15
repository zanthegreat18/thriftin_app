import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/services/buy_service.dart';
import 'package:thriftin_app/transaksi/bloc/buy_bloc.dart';
import 'package:thriftin_app/transaksi/bloc/buy_event.dart';
import 'package:thriftin_app/transaksi/bloc/buy_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BuyBloc(BuyService())..add(FetchBuyHistory()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Cart / Riwayat Pembelian"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: BlocBuilder<BuyBloc, BuyState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Text("Terjadi kesalahan: ${state.error!}"),
              );
            }

            if (state.history.isEmpty) {
              return const Center(
                child: Text("Belum ada pembelian 😶"),
              );
            }

            // Hitung total harga
            int total = 0;
            for (var item in state.history) {
              final produk = item['produk'];
              if (produk != null) {
                final harga = int.tryParse(produk['harga'].toString()) ?? 0;
                final jumlah = int.tryParse(item['jumlah'].toString()) ?? 0;
                total += harga * jumlah;
              }
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: state.history.length,
                    itemBuilder: (context, index) {
                      final item = state.history[index];
                      final produk = item['produk'];

                      if (produk == null) {
                        return const Card(
                          child: ListTile(
                            title: Text("Produk tidak ditemukan"),
                          ),
                        );
                      }

                      final harga = produk['harga'] ?? '0';
                      final jumlah = item['jumlah'] ?? '1';

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: produk['gambar'] != null
                                ? Image.network(
                                    'http://10.0.2.2:8000/storage/${produk['gambar']}',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image, size: 40),
                                  )
                                : const Icon(Icons.shopping_bag),
                          ),
                          title: Text(
                            produk['nama_produk'] ?? 'Produk',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Jumlah: $jumlah",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          trailing: Text(
                            "Rp $harga",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(top: BorderSide(color: Colors.grey, width: 0.2)),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Pembelian",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Rp $total",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
