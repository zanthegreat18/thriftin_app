import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8000/api"));

  Future<String> login(String email, String password) async {
    final res = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });

    return res.data['token'];
  }

  Future<String> getRole(String token) async {
  final res = await _dio.get('/me',
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );

  return res.data['role'];
  }

  Future<String> register(String name, String email, String password) async {
    final res = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });

    return res.data['token'];
  }
}