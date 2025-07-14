import 'package:dio/dio.dart';
 // Sesuai file API base URL kamu

class BuyService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api'));

  Future<void> buyProduct({
    required int produkId,
    required int jumlah,
    required String token,
  }) async {
    final response = await _dio.post(
      '/buy',
      data: {'produk_id': produkId, 'jumlah': jumlah},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode != 201) {
      throw Exception('Gagal membeli produk');
    }
  }

  Future<List<dynamic>> getBuyHistory(String token) async {
    final response = await _dio.get(
      '/buy/history',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'];
  }
}
