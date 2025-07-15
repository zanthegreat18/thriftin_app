import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8000/api"));

  Dio get dio => _dio;

  // ✅ Login
  Future<String> login(String email, String password) async {
    final res = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });

    final token = res.data['token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    // Ambil data user
    final userRes = await _dio.get('/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    final name = userRes.data['name'];
    final emailUser = userRes.data['email'];

    await prefs.setString('name', name);
    await prefs.setString('email', emailUser);

    // Default role
    await prefs.setBool('isCompany', false);

    return token;
  }

  // ✅ Register
  Future<String> register(String name, String email, String password) async {
    final res = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });

    final token = res.data['token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('name', name);
    await prefs.setString('email', email);

    // Default role
    await prefs.setBool('isCompany', false);

    return token;
  }

  // ✅ Optional: Get role
  Future<String> getRole(String token) async {
    final res = await _dio.get('/me',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return res.data['role'];
  }

  // ✅ Get token yang disimpan
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token tidak ditemukan');
    return token;
  }

  // ✅ Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // bersihin semua sekalian
  }

  // ✅ Get data user dari endpoint /me
  Future<Map<String, dynamic>> getUser() async {
    final token = await getToken();
    final res = await _dio.get('/me', options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ));
    return res.data;
  }

  // ✅ Upgrade ke akun company (local only for now)
  static Future<void> upgradeToCompany() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCompany', true);
  }

  // ✅ Cek apakah udah jadi company
  static Future<bool> isCompanyAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isCompany') ?? false;
  }

  // ✅ Tambahan: Get daftar akun company dari endpoint /companies
  Future<List<Map<String, dynamic>>> getCompanies() async {
    final token = await getToken();
    final res = await _dio.get(
      '/companies',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    } else {
      throw Exception("Gagal mengambil data company.");
    }
  }
}
