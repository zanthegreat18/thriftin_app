import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8000/api"));

  // Token simpan pas login
  Future<String> login(String email, String password) async {
    final res = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });

    final token = res.data['token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    return token;
  }

  // Auth Register
  Future<String> register(String name, String email, String password) async {
    final res = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });

    final token = res.data['token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    return token;
  }

  // ✅ Ambil role user dari token
  Future<String> getRole(String token) async {
    final res = await _dio.get('/me',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return res.data['role'];
  }

  // ✅ Ambil token yang disimpan
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token tidak ditemukan');
    return token;
  }

  // ✅ Logout (hapus token)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}