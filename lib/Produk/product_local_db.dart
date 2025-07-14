// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:thriftin_app/models/product_models.dart';

// class ProductLocalDB {
//   static Database? _db;

//   Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await _initDB();
//     return _db!;
//   }

//   Future<Database> _initDB() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'product.db');

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE user_products (
//             id INTEGER PRIMARY KEY,
//             user_id INTEGER,
//             nama_produk TEXT,
//             deskripsi TEXT,
//             harga INTEGER,
//             gambar TEXT,
//             lokasi_lat REAL,
//             lokasi_lng REAL
//           )
//         ''');

//         await db.execute('''
//           CREATE TABLE all_products (
//             id INTEGER PRIMARY KEY,
//             user_id INTEGER,
//             nama_produk TEXT,
//             deskripsi TEXT,
//             harga INTEGER,
//             gambar TEXT,
//             lokasi_lat REAL,
//             lokasi_lng REAL
//           )
//         ''');
//       },
//     );
//   }

//   // ==================== USER PRODUCTS ====================

//   Future<void> insertUserProducts(List<Product> products) async {
//     final db = await database;
//     final batch = db.batch();

//     batch.delete('user_products');
//     for (var product in products) {
//       batch.insert('user_products', product.toMap());
//     }

//     await batch.commit(noResult: true);
//   }

//   Future<List<Product>> getUserProducts() async {
//     final db = await database;
//     final result = await db.query('user_products');
//     return result.map((e) => Product.fromMap(e)).toList();
//   }

//   Future<void> deleteProduct(int productId) async {
//     final db = await database;
//     await db.delete('products', where: 'id = ?', whereArgs: [productId]);
//   }

//   // ==================== ALL PRODUCTS ====================

//   Future<void> insertAllProducts(List<Product> products) async {
//     final db = await database;
//     final batch = db.batch();

//     batch.delete('all_products');
//     for (var product in products) {
//       batch.insert('all_products', product.toMap());
//     }

//     await batch.commit(noResult: true);
//   }

//   Future<List<Product>> getAllProducts() async {
//     final db = await database;
//     final result = await db.query('all_products');
//     return result.map((e) => Product.fromMap(e)).toList();
//   }
// }
