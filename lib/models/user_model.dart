class UserModel {
  final int id;
  final String name;
  final String email;
  final String? token; // optional, biar bisa dipakai saat login

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      token: json['token'], // token biasanya dikirim saat login
    );
  }
}