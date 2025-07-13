class Product {
  final int id;
  final int userId;
  final String namaProduk;
  final String deskripsi;
  final int harga;
  final String gambar;
  final double lokasiLat;
  final double lokasiLng;

  Product({
    required this.id,
    required this.userId,
    required this.namaProduk,
    required this.deskripsi,
    required this.harga,
    required this.gambar,
    required this.lokasiLat,
    required this.lokasiLng,
  });

  /// ✅ Convert dari JSON (API response) ke objek Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      userId: json['user_id'] is String ? int.parse(json['user_id']) : json['user_id'],
      namaProduk: json['nama_produk'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: json['harga'] is String ? int.parse(json['harga']) : json['harga'],
      gambar: json['gambar'] ?? '',
      lokasiLat: double.tryParse(json['lokasi_lat'].toString()) ?? 0.0,
      lokasiLng: double.tryParse(json['lokasi_lng'].toString()) ?? 0.0,
    );
  }

  /// ✅ Convert ke Map buat disimpan di SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nama_produk': namaProduk,
      'deskripsi': deskripsi,
      'harga': harga,
      'gambar': gambar,
      'lokasi_lat': lokasiLat,
      'lokasi_lng': lokasiLng,
    };
  }

  /// ✅ Convert dari SQLite Map ke object Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] is String ? int.parse(map['id']) : map['id'],
      userId: map['user_id'] is String ? int.parse(map['user_id']) : map['user_id'],
      namaProduk: map['nama_produk'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      harga: map['harga'] is String ? int.parse(map['harga']) : map['harga'],
      gambar: map['gambar'] ?? '',
      lokasiLat: double.tryParse(map['lokasi_lat'].toString()) ?? 0.0,
      lokasiLng: double.tryParse(map['lokasi_lng'].toString()) ?? 0.0,
    );
  }
}
