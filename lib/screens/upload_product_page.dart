import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thriftin_app/Produk/bloc/product_bloc.dart';
import 'package:thriftin_app/Produk/bloc/product_event.dart';
import 'package:thriftin_app/Produk/bloc/product_state.dart';
import 'package:thriftin_app/screens/map_picker_page.dart';

class UploadProductPage extends StatelessWidget {
  const UploadProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    final nameC = TextEditingController();
    final descC = TextEditingController();
    final priceC = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Produk"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Produk berhasil diupload")),
            );
            Navigator.pop(context);
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFormCard(
                  children: [
                    TextField(
                      controller: nameC,
                      decoration: _inputDecoration("Nama Produk"),
                      onChanged: (val) => productBloc.add(ProductNameChanged(val)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descC,
                      maxLines: 3,
                      decoration: _inputDecoration("Deskripsi Produk"),
                      onChanged: (val) => productBloc.add(ProductDescriptionChanged(val)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceC,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Harga (Rp)"),
                      onChanged: (val) => productBloc.add(ProductPriceChanged(val)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Gambar
                _buildFormCard(
                  children: [
                    state.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(state.image!, height: 200, fit: BoxFit.cover),
                          )
                        : const Text("Belum ada gambar dipilih"),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          productBloc.add(ProductImagePicked(File(picked.path)));
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: const Text("Pilih Gambar"),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Lokasi
                _buildFormCard(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.lat != null && state.lng != null
                                ? "Lokasi: (${state.lat!.toStringAsFixed(4)}, ${state.lng!.toStringAsFixed(4)})"
                                : "Belum ada lokasi dipilih",
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            final picked = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MapPickerPage()),
                            );
                            if (picked != null) {
                              final pos = picked as LatLng;
                              productBloc.add(ProductLocationPicked(pos.latitude, pos.longitude));
                            }
                          },
                          child: const Text("Pilih Lokasi"),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Tombol Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: state.isSubmitting ? null : () => productBloc.add(ProductSubmitted()),
                    icon: state.isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.upload),
                    label: const Text("Upload Produk"),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // Bottom Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) {
          // Sesuaikan ini sama route kamu
          if (index == 0) Navigator.pushNamed(context, '/user-dashboard');
          if (index == 2) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildFormCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}