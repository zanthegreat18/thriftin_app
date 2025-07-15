import 'package:dio/dio.dart';
import 'package:thriftin_app/services/auth_service.dart';

class LaporanService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api'));

  // ✅ Kirim laporan
  Future<void> submitLaporan(int produkId, String alasan) async {
    final token = await AuthService.getToken();

    try {
      final res = await _dio.post(
        '/lapor',
        data: {
          'produk_id': produkId,
          'alasan': alasan,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (res.statusCode != 201) {
        throw Exception("Gagal mengirim laporan");
      }
    } catch (e) {
      print("Error submitLaporan: $e");
      rethrow;
    }
  }

  // ✅ Ambil semua laporan (admin)
  Future<List<Map<String, dynamic>>> fetchAllLaporan() async {
    final token = await AuthService.getToken();

    try {
      final res = await _dio.get(
        '/admin/laporan',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return List<Map<String, dynamic>>.from(res.data);
    } catch (e) {
      print("Error fetchAllLaporan: $e");
      rethrow;
    }
  }

  // ✅ Update status laporan
  Future<void> updateStatus(int laporanId, String status) async {
    final token = await AuthService.getToken();

    try {
      final res = await _dio.put(
        '/admin/laporan/$laporanId/status',
        data: {'status': status},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (res.statusCode != 200) {
        throw Exception("Gagal update status");
      }
    } catch (e) {
      print("Error updateStatus: $e");
      rethrow;
    }
  }
}
