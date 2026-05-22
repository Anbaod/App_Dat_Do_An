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
      version: 6,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT,
        address TEXT,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image TEXT NOT NULL,
        price REAL NOT NULL,
        rate TEXT,
        rating TEXT,
        type TEXT,
        food_type TEXT,
        category TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        address TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        image TEXT NOT NULL,
        price REAL NOT NULL,
        qty INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image TEXT NOT NULL,
        price REAL NOT NULL,
        qty INTEGER NOT NULL,
        size TEXT,
        ingredients TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image TEXT NOT NULL,
        price REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        is_read INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute(
          "ALTER TABLE orders ADD COLUMN status TEXT NOT NULL DEFAULT 'Đang xử lý'",
        );
      } catch (_) {}

      await db.execute('''
        CREATE TABLE IF NOT EXISTS order_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          image TEXT NOT NULL,
          price REAL NOT NULL,
          qty INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS cart (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          image TEXT NOT NULL,
          price REAL NOT NULL,
          qty INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          image TEXT NOT NULL,
          price REAL NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          is_read INTEGER NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          phone TEXT,
          address TEXT,
          password TEXT NOT NULL,
          role TEXT NOT NULL DEFAULT 'user',
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS foods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          image TEXT NOT NULL,
          price REAL NOT NULL,
          rate TEXT,
          rating TEXT,
          type TEXT,
          food_type TEXT,
          category TEXT,
          description TEXT
        )
      ''');
    }

    if (oldVersion < 4) {
      try {
        await db.execute(
          "ALTER TABLE users ADD COLUMN password TEXT NOT NULL DEFAULT '123456'",
        );
      } catch (_) {}
    }

    if (oldVersion < 5) {
      try {
        await db.execute(
          "ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'user'",
        );
      } catch (_) {}
      
      // Tạo tài khoản admin mặc định
      await db.insert(
        "users",
        {
          "name": "Admin",
          "email": "admin@gmail.com",
          "password": "123",
          "phone": "",
          "address": "",
          "role": "admin",
          "created_at": DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    if (oldVersion < 6) {
      try {
        await db.execute("ALTER TABLE cart ADD COLUMN size TEXT");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE cart ADD COLUMN ingredients TEXT");
      } catch (_) {}
    }
  }



  Future<int> insertUser({
    required String name,
    required String email,
    required String password,
    String phone = "",
    String address = "",
    String role = "user",
  }) async {
    final db = await instance.database;

    return await db.insert(
      "users",
      {
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
        "address": address,
        "role": role,
        "created_at": DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await instance.database;

    return await db.query(
      "users",
      orderBy: "id DESC",
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;

    final result = await db.query(
      "users",
      where: "email = ?",
      whereArgs: [email],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<Map<String, dynamic>?> getUserByEmailAndPassword(String email, String password) async {
    final db = await instance.database;

    final result = await db.query(
      "users",
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<int> updateUserPassword(String email, String newPassword) async {
    final db = await instance.database;

    return await db.update(
      "users",
      {"password": newPassword},
      where: "email = ?",
      whereArgs: [email],
    );
  }

  Future<int> updateUser({
    required int id,
    required String name,
    required String email,
    String phone = "",
    String address = "",
  }) async {
    final db = await instance.database;

    return await db.update(
      "users",
      {
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;

    return await db.delete(
      "users",
      where: "id = ?",
      whereArgs: [id],
    );
  }


  Future<int> insertFood({
    required String name,
    required String image,
    required double price,
    String rate = "4.5",
    String rating = "0",
    String type = "Food",
    String foodType = "Fast Food",
    String category = "Food",
    String description = "",
  }) async {
    final db = await instance.database;

    return await db.insert("foods", {
      "name": name,
      "image": image,
      "price": price,
      "rate": rate,
      "rating": rating,
      "type": type,
      "food_type": foodType,
      "category": category,
      "description": description,
    });
  }

  Future<List<Map<String, dynamic>>> getFoods() async {
    final db = await instance.database;

    return await db.query(
      "foods",
      orderBy: "id DESC",
    );
  }

  Future<List<Map<String, dynamic>>> getFoodsByCategory(String category) async {
    final db = await instance.database;

    return await db.query(
      "foods",
      where: "category = ?",
      whereArgs: [category],
      orderBy: "id DESC",
    );
  }

  Future<List<Map<String, dynamic>>> searchFoods(String keyword) async {
    final db = await instance.database;

    return await db.query(
      "foods",
      where: "name LIKE ? OR type LIKE ? OR food_type LIKE ? OR category LIKE ?",
      whereArgs: [
        "%$keyword%",
        "%$keyword%",
        "%$keyword%",
        "%$keyword%",
      ],
      orderBy: "id DESC",
    );
  }

  Future<int> updateFood({
    required int id,
    required String name,
    required String image,
    required double price,
    String rate = "4.5",
    String rating = "0",
    String type = "Food",
    String foodType = "Fast Food",
    String category = "Food",
    String description = "",
  }) async {
    final db = await instance.database;

    return await db.update(
      "foods",
      {
        "name": name,
        "image": image,
        "price": price,
        "rate": rate,
        "rating": rating,
        "type": type,
        "food_type": foodType,
        "category": category,
        "description": description,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteFood(int id) async {
    final db = await instance.database;

    return await db.delete(
      "foods",
      where: "id = ?",
      whereArgs: [id],
    );
  }



  Future<int> insertOrder({
    required String address,
    required String paymentMethod,
    required double total,
    String status = "Đang xử lý",
  }) async {
    final db = await instance.database;

    return await db.insert("orders", {
      "address": address,
      "payment_method": paymentMethod,
      "total": total,
      "status": status,
      "created_at": DateTime.now().toIso8601String(),
    });
  }

  Future<int> insertOrderWithItems({
    required String address,
    required String paymentMethod,
    required double total,
    required List<Map<String, dynamic>> items,
    String status = "Đang xử lý",
  }) async {
    final db = await instance.database;

    int orderId = await db.insert("orders", {
      "address": address,
      "payment_method": paymentMethod,
      "total": total,
      "status": status,
      "created_at": DateTime.now().toIso8601String(),
    });

    for (var item in items) {
      await db.insert("order_items", {
        "order_id": orderId,
        "name": item["name"]?.toString() ?? "Món ăn",
        "image": item["image"]?.toString() ?? "assets/img/menu_1.png",
        "price": double.tryParse(item["price"].toString()) ?? 0.0,
        "qty": int.tryParse(item["qty"].toString()) ?? 1,
      });
    }

    return orderId;
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await instance.database;

    return await db.query(
      "orders",
      orderBy: "id DESC",
    );
  }

  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    final db = await instance.database;

    return await db.query(
      "order_items",
      where: "order_id = ?",
      whereArgs: [orderId],
    );
  }

  Future<int> updateOrderStatus(int id, String status) async {
    final db = await instance.database;

    return await db.update(
      "orders",
      {"status": status},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteOrder(int id) async {
    final db = await instance.database;

    await db.delete(
      "order_items",
      where: "order_id = ?",
      whereArgs: [id],
    );

    return await db.delete(
      "orders",
      where: "id = ?",
      whereArgs: [id],
    );
  }



  Future<int> insertCart({
    required String name,
    required String image,
    required double price,
    required int qty,
    String? size,
    String? ingredients,
  }) async {
    final db = await instance.database;

    List<Map<String, dynamic>> oldItems;
    if (size == null && ingredients == null) {
      oldItems = await db.query(
        "cart",
        where: "name = ? AND size IS NULL AND ingredients IS NULL",
        whereArgs: [name],
      );
    } else if (size != null && ingredients == null) {
      oldItems = await db.query(
        "cart",
        where: "name = ? AND size = ? AND ingredients IS NULL",
        whereArgs: [name, size],
      );
    } else if (size == null && ingredients != null) {
      oldItems = await db.query(
        "cart",
        where: "name = ? AND size IS NULL AND ingredients = ?",
        whereArgs: [name, ingredients],
      );
    } else {
      oldItems = await db.query(
        "cart",
        where: "name = ? AND size = ? AND ingredients = ?",
        whereArgs: [name, size, ingredients],
      );
    }

    if (oldItems.isNotEmpty) {
      final oldItem = oldItems.first;
      final oldQty = int.tryParse(oldItem["qty"].toString()) ?? 0;

      return await db.update(
        "cart",
        {
          "qty": oldQty + qty,
        },
        where: "id = ?",
        whereArgs: [oldItem["id"]],
      );
    }

    return await db.insert("cart", {
      "name": name,
      "image": image,
      "price": price,
      "qty": qty,
      "size": size,
      "ingredients": ingredients,
    });
  }

  Future<List<Map<String, dynamic>>> getCart() async {
    final db = await instance.database;

    return await db.query(
      "cart",
      orderBy: "id DESC",
    );
  }

  Future<int> updateCartQty(int id, int qty) async {
    final db = await instance.database;

    if (qty <= 0) {
      return await deleteCartItem(id);
    }

    return await db.update(
      "cart",
      {"qty": qty},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteCartItem(int id) async {
    final db = await instance.database;

    return await db.delete(
      "cart",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> clearCart() async {
    final db = await instance.database;

    return await db.delete("cart");
  }



  Future<int> insertFavorite({
    required String name,
    required String image,
    required double price,
  }) async {
    final db = await instance.database;

    final oldItems = await db.query(
      "favorites",
      where: "name = ?",
      whereArgs: [name],
    );

    if (oldItems.isNotEmpty) {
      return oldItems.first["id"] as int;
    }

    return await db.insert("favorites", {
      "name": name,
      "image": image,
      "price": price,
    });
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await instance.database;

    return await db.query(
      "favorites",
      orderBy: "id DESC",
    );
  }

  Future<bool> isFavorite(String name) async {
    final db = await instance.database;

    final result = await db.query(
      "favorites",
      where: "name = ?",
      whereArgs: [name],
    );

    return result.isNotEmpty;
  }

  Future<int> deleteFavoriteByName(String name) async {
    final db = await instance.database;

    return await db.delete(
      "favorites",
      where: "name = ?",
      whereArgs: [name],
    );
  }



  Future<int> insertNotification({
    required String title,
    required String message,
  }) async {
    final db = await instance.database;

    return await db.insert("notifications", {
      "title": title,
      "message": message,
      "is_read": 0,
      "created_at": DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await instance.database;

    return await db.query(
      "notifications",
      orderBy: "id DESC",
    );
  }

  Future<int> markNotificationRead(int id) async {
    final db = await instance.database;

    return await db.update(
      "notifications",
      {"is_read": 1},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> markAllNotificationsRead() async {
    final db = await instance.database;

    return await db.update(
      "notifications",
      {"is_read": 1},
    );
  }

  Future<int> deleteNotification(int id) async {
    final db = await instance.database;

    return await db.delete(
      "notifications",
      where: "id = ?",
      whereArgs: [id],
    );
  }



  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}