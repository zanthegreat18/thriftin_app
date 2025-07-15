import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  final Dio _dio = Dio();

  Future<void> uploadProduct({
    required String nama,
    required String deskripsi,
    required int harga,
    required double latitude,
    required double longitude,
    required File imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final formData = FormData.fromMap({
        'nama_produk': nama,
        'deskripsi': deskripsi,
        'harga': harga,
        'lokasi_lat': latitude,
        'lokasi_lng': longitude,
        'gambar': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        'http://10.0.2.2:8000/api/produk',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Gagal upload produk: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception("Upload error: $e");
    }
  }

  Future<List<dynamic>> fetchProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await _dio.get(
        'http://10.0.2.2:8000/api/produk',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Gagal mengambil data produk: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception("Fetch error: $e");
    }
  }

  Future<List<dynamic>> fetchAllProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await _dio.get(
        'http://10.0.2.2:8000/api/produk/all',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print("RESP STATUS: ${response.statusCode}");
      print("RESP DATA: ${response.data}");

      if (response.statusCode == 200) {
        dynamic body = response.data;

        // Jika masih string (kadang Laravel bisa begitu), parse dulu
        if (body is String) {
          body = body.trim();
          if (body.isEmpty) throw Exception('Response kosong');
          body = json.decode(body);
        }

        // Validasi ada key 'data'
        if (body is Map && body.containsKey('data')) {
          return List<Map<String, dynamic>>.from(body['data']);
        } else {
          throw Exception("Format data tidak valid");
        }
      } else {
        throw Exception('Gagal mengambil semua produk: ${response.statusMessage}');
      }
    } catch (e) {
      print("Fetch All Produk error: $e");
      throw Exception("Fetch All Produk error: $e");
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await _dio.delete(
        'http://10.0.2.2:8000/api/produk/$productId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus produk: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception("Delete error: $e");
    }
  }

  Future<void> updateProduct({
    required int id,
    required String nama,
    required String deskripsi,
    required int harga,
    required double latitude,
    required double longitude,
    File? imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final data = {
        'nama_produk': nama,
        'deskripsi': deskripsi,
        'harga': harga,
        'lokasi_lat': latitude,
        'lokasi_lng': longitude,
      };

      if (imageFile != null) {
        data['gambar'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(data);

      final response = await _dio.put(
        'http://10.0.2.2:8000/api/produk/$id',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal update produk: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception("Update error: $e");
    }
  }

  // ✅ Tambahan method baru buat ambil produk berdasarkan user ID
  Future<List<Map<String, dynamic>>> getProductsByUser(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await _dio.get(
        'http://10.0.2.2:8000/api/user/$userId/produk',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception('Gagal mengambil produk user: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception("Get by user error: $e");
    }
  }
}