import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thriftin_app/services/product_service.dart';

class UploadProductPage extends StatefulWidget {
  const UploadProductPage({super.key});

  @override
  State<UploadProductPage> createState() => _UploadProductPageState();
}

class _UploadProductPageState extends State<UploadProductPage> {
  final _nameC = TextEditingController();
  final _descC = TextEditingController();
  final _priceC = TextEditingController();
  File? _selectedImage;
  double? _latitude;
  double? _longitude;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GPS belum aktif. Aktifkan dulu bro!')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi ditolak!')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      debugPrint('Lokasi error: $e');
    }
  }

  void _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _uploadProduct() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gambar terlebih dahulu")),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tunggu lokasi didapatkan...")),
      );
      return;
    }

    try {
      await ProductService().uploadProduct(
        nama: _nameC.text,
        deskripsi: _descC.text,
        harga: int.parse(_priceC.text),
        latitude: _latitude!,
        longitude: _longitude!,
        imageFile: _selectedImage!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk berhasil diupload")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameC,
              decoration: const InputDecoration(labelText: "Nama Produk"),
            ),
            TextField(
              controller: _descC,
              decoration: const InputDecoration(labelText: "Deskripsi"),
            ),
            TextField(
              controller: _priceC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Harga"),
            ),
            const SizedBox(height: 16),
            _selectedImage == null
                ? const Text("Belum ada gambar", style: TextStyle(color: Colors.grey))
                : Image.file(_selectedImage!, height: 200),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Pilih Gambar"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadProduct,
              child: const Text("Upload Produk"),
            ),
            const SizedBox(height: 20),
            if (_latitude != null && _longitude != null)
              Text(
                "Lokasi Terdeteksi: $_latitude, $_longitude",
                style: const TextStyle(color: Colors.green),
              )
            else
              const Text(
                "Mendeteksi lokasi...",
                style: TextStyle(color: Colors.orange),
              ),
          ],
        ),
      ),
    );
  }
}
