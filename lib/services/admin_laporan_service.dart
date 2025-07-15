import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thriftin_app/services/auth_service.dart';

class AdminLaporanService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  // 🔥 Ambil semua laporan
  Future<List<Map<String, dynamic>>> fetchAllLaporan() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/admin/laporan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) throw Exception("Gagal ambil laporan");
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  // 🔥 Update status laporan
  Future<void> updateStatus(int laporanId, String status) async {
    final token = await AuthService.getToken();
    final res = await http.put(
      Uri.parse('$baseUrl/admin/laporan/$laporanId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': status}),
    );

    if (res.statusCode != 200) throw Exception("Gagal update status");
  }

  // 🔥 Hapus produk dari laporan
  Future<void> deleteProduk(int produkId) async {
    final token = await AuthService.getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/produk/$produkId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) throw Exception("Gagal hapus produk");
  }
}