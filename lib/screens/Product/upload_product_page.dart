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
        elevation: 1,
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state.success) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Produk berhasil diupload 🎉")),
              );
              context.read<ProductBloc>().add(ProductFetched());
              Navigator.pushReplacementNamed(context, '/product-list');
            });
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
                _buildFormCard([
                  _buildTextField("Nama Produk", nameC, Icons.edit, (val) {
                    productBloc.add(ProductNameChanged(val));
                  }),
                  const SizedBox(height: 12),
                  _buildTextField("Deskripsi Produk", descC, Icons.description, (val) {
                    productBloc.add(ProductDescriptionChanged(val));
                  }, maxLines: 3),
                  const SizedBox(height: 12),
                  _buildTextField("Harga (Rp)", priceC, Icons.attach_money, (val) {
                    productBloc.add(ProductPriceChanged(val));
                  }, inputType: TextInputType.number),
                ]),
                const SizedBox(height: 16),
                _buildFormCard([
                  state.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            state.image!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Text("Belum ada gambar dipilih 🖼️"),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.image_search),
                    label: const Text("Pilih Gambar"),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        productBloc.add(ProductImagePicked(File(picked.path)));
                      }
                    },
                  ),
                ]),
                const SizedBox(height: 16),
                _buildFormCard([
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.lat != null && state.lng != null
                              ? "Lokasi: (${state.lat!.toStringAsFixed(4)}, ${state.lng!.toStringAsFixed(4)})"
                              : "Belum ada lokasi dipilih",
                          style: const TextStyle(fontSize: 14),
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
                  )
                ]),
                const SizedBox(height: 24),

                // ✅ Rounded Upload Button with Icon
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: state.isSubmitting
                        ? null
                        : () {
                            if (state.image == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Gambar harus dipilih dulu 📸")),
                              );
                              return;
                            }
                            productBloc.add(ProductSubmitted());
                          },
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: state.isSubmitting ? Colors.grey : Colors.black,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: state.isSubmitting
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    Function(String) onChanged, {
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
}
