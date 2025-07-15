import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:thriftin_app/Produk/bloc/product_bloc.dart';
import 'package:thriftin_app/Produk/bloc/product_state.dart';
import 'package:thriftin_app/services/auth_service.dart';
import 'package:thriftin_app/services/buy_service.dart';
import 'package:thriftin_app/transaksi/bloc/buy_bloc.dart';
import 'package:thriftin_app/transaksi/bloc/buy_event.dart';
import 'package:thriftin_app/transaksi/bloc/buy_state.dart';

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

    return BlocProvider(
      create: (_) => BuyBloc(BuyService()),
      child: Builder(
        builder: (context) {
          return BlocListener<BuyBloc, BuyState>(
            listener: (context, state) {
              if (state.isSuccess) {
                Navigator.pushNamed(context, '/cart');
              } else if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!)),
                );
              }
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    // Gambar Produk & Tombol Laporan
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
                        Positioned(
                          top: 16,
                          left: 16,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: IconButton(
                            icon: const Icon(Icons.report, color: Colors.red),
                            tooltip: "Laporkan produk ini",
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => _ReportDialog(produkId: product['id']),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // Info Produk
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView(
                          children: [
                            Text(
                              "Rp ${product['harga']}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              product['deskripsi'] ?? '-',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 24),
                            if (product['lokasi_lat'] != null && product['lokasi_lng'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Lokasi Produk", style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: FutureBuilder<String>(
                                          future: getAddress(
                                            double.parse(product['lokasi_lat'].toString()),
                                            double.parse(product['lokasi_lng'].toString()),
                                          ),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return const Text("Memuat alamat...");
                                            } else if (snapshot.hasError) {
                                              return const Text("Gagal memuat alamat");
                                            } else {
                                              return Text(snapshot.data ?? "-", style: const TextStyle(fontSize: 14));
                                            }
                                          },
                                        ),
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
                          ],
                        ),
                      ),
                    ),

                    // Tombol Bawah
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
                              onPressed: () {
                                // Add to cart (belum implement)
                              },
                              child: const Text("Chat Owner"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                final id = product['id'];
                                context.read<BuyBloc>().add(
                                  BuyProductRequested(produkId: id, jumlah: 1),
                                );
                              },
                              child: const Text("Buy now"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<String> getAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      final place = placemarks.first;
      return "${place.street}, ${place.subLocality}, ${place.locality}";
    } catch (e) {
      return "Alamat tidak ditemukan";
    }
  }
}

class _ReportDialog extends StatefulWidget {
  final int produkId;

  const _ReportDialog({required this.produkId});

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _alasanController = TextEditingController();
  bool _isSubmitting = false;

    Future<void> _submitReport() async {
    final alasan = _alasanController.text.trim();
    if (alasan.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final token = await AuthService.getToken(); // Ambil token login

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/lapor'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Kirim token
        },
        body: jsonEncode({
          "produk_id": widget.produkId,
          "alasan": alasan,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Laporan berhasil dikirim!")),
        );
      } else {
        print(response.body);
        throw Exception("Gagal kirim laporan");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Laporkan Produk"),
      content: TextField(
        controller: _alasanController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: "Masukkan alasan laporan...",
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReport,
          child: _isSubmitting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Kirim"),
        ),
      ],
    );
  }
}
