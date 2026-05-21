import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();

  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB("food_delivery.db");
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        address TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        total REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertOrder({
    required String address,
    required String paymentMethod,
    required double total,
  }) async {
    final db = await instance.database;

    return await db.insert("orders", {
      "address": address,
      "payment_method": paymentMethod,
      "total": total,
      "created_at": DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await instance.database;

    return await db.query(
      "orders",
      orderBy: "id DESC",
    );
  }

  Future<int> deleteOrder(int id) async {
    final db = await instance.database;

    return await db.delete(
      "orders",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}