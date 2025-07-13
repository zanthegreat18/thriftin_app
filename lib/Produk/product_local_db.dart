import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:thriftin_app/models/product_models.dart';

 // pastiin ini path-nya bener ya

class ProductLocalDB {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'product.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        nama_produk TEXT,
        deskripsi TEXT,
        harga INTEGER,
        gambar TEXT,
        lokasi_lat REAL,
        lokasi_lng REAL
      )
    ''');
  }

    Future<void> insertProducts(List<Product> products) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('products'); // Bersihin dulu di dalam transaksi

      for (final product in products) {
        await txn.insert('products', product.toMap());
      }
    });
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('products');

    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<void> clearProducts() async {
    final db = await database;
    await db.delete('products');
  }

  Future<void> deleteProduct(int productId) async {}
}