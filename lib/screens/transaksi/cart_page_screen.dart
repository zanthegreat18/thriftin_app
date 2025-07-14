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
              return Center(child: Text("Terjadi kesalahan: ${state.error!}"));
            }

            if (state.history.isEmpty) {
              return const Center(child: Text("Belum ada pembelian 😶"));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const Divider(),
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final item = state.history[index];
                final produk = item['produk'];

                if (produk == null) {
                  return const ListTile(
                    title: Text("Produk tidak ditemukan"),
                  );
                }

                return ListTile(
                  leading: produk['gambar'] != null
                      ? Image.network(
                          'http://10.0.2.2:8000/storage/${produk['gambar']}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 40),
                        )
                      : const Icon(Icons.shopping_bag),
                  title: Text(produk['nama_produk'] ?? 'Produk'),
                  subtitle: Text("Jumlah: ${item['jumlah']}"),
                  trailing: Text(
                    "Rp ${produk['harga']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}