import 'package:flutter/material.dart';
import 'package:thriftin_app/services/product_service.dart';

class CompanyProfilePage extends StatelessWidget {
  final int companyId;
  final String companyName;

  const CompanyProfilePage({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(companyName),
        backgroundColor: Colors.brown.shade400,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ProductService().getProductsByUser(companyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada produk."));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: product['gambar'] != null
                    ? Image.network('http://10.0.2.2:8000/storage/${product['gambar']}', width: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported),
                title: Text(product['nama_produk']),
                subtitle: Text(product['deskripsi'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
