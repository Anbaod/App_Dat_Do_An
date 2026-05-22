import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();

  static Database? _database;

  DBHelper._init();

  static const _databaseName = "food_delivery_v5.db";
  static const _databaseVersion = 5;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: _databaseVersion,
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
        role TEXT NOT NULL DEFAULT 'user',
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
        is_reviewed INTEGER NOT NULL DEFAULT 0,
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
        qty INTEGER NOT NULL
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

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE offers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image TEXT NOT NULL,
        discount TEXT NOT NULL,
        price REAL DEFAULT 0.0,
        type TEXT,
        food_type TEXT,
        rate TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_used_offers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        offer_id INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        user_email TEXT NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        is_hidden INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await _seedCategories(db);
    await _seedFoods(db);

    // Seed admin user
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
        await db.execute('''
          CREATE TABLE IF NOT EXISTS reviews (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL,
            user_email TEXT NOT NULL,
            rating INTEGER NOT NULL,
            comment TEXT,
            is_hidden INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute(
          "ALTER TABLE orders ADD COLUMN is_reviewed INTEGER NOT NULL DEFAULT 0",
        );
      } catch (_) {}
    }

    if (oldVersion < 7) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            image TEXT,
            created_at TEXT
          )
        ''');
        await _seedCategories(db);
        await _seedFoods(db);
      } catch (_) {}
    }

    if (oldVersion < 8) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS offers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            image TEXT NOT NULL,
            discount TEXT NOT NULL,
            price REAL DEFAULT 0.0,
            type TEXT,
            food_type TEXT,
            rate TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      } catch (_) {}
    }

    if (oldVersion < 9) {
      try {
        await db.execute("ALTER TABLE offers ADD COLUMN price REAL DEFAULT 0.0");
      } catch (_) {}
    }
  }

  Future<void> _seedCategories(Database db) async {
    final categories = [
      {"name": "Phở", "image": "assets/img/pho_bo.png"},
      {"name": "Bánh Mì", "image": "assets/img/banh_mi.png"},
      {"name": "Cơm", "image": "assets/img/com_tam.png"},
      {"name": "Bún", "image": "assets/img/bun_cha.png"},

    ];
    for (var cat in categories) {
      await db.insert("categories", {
        "name": cat["name"],
        "image": cat["image"],
        "created_at": DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _seedFoods(Database db) async {
    final foods = [
      {
        "name": "Phở Bò Đặc Biệt",
        "image": "assets/img/pho_bo.png",
        "price": 55000.0,
        "rate": "4.9",
        "category": "Phở",
        "description": "Phở bò nấu theo hương vị truyền thống, đậm đà.",
        "food_type": "Món Nước",
        "type": "Món Chính"
      },
      {
        "name": "Phở Gà Ta",
        "image": "assets/img/pho_ga.png",
        "price": 45000.0,
        "rate": "4.7",
        "category": "Phở",
        "description": "Phở gà ta dai ngon, nước dùng thanh ngọt.",
        "food_type": "Món Nước",
        "type": "Món Chính"
      },
      {
        "name": "Phở Trộn Cuốn",
        "image": "assets/img/pho_cuon.png",
        "price": 50000.0,
        "rate": "4.8",
        "category": "Phở",
        "description": "Phở trộn chua ngọt, dễ ăn và chống ngán.",
        "food_type": "Món Trộn",
        "type": "Món Chính"
      },
      {
        "name": "Bánh Mì Thịt Nướng",
        "image": "assets/img/banh_mi.png",
        "price": 25000.0,
        "rate": "4.8",
        "category": "Bánh Mì",
        "description": "Bánh mì giòn rụm với thịt nướng thơm lừng.",
        "food_type": "Ăn Nhanh",
        "type": "Món Chính"
      },
      {
        "name": "Bánh Mì Chả Lụa",
        "image": "assets/img/banh_mi_cha.png",
        "price": 20000.0,
        "rate": "4.6",
        "category": "Bánh Mì",
        "description": "Bánh mì truyền thống với chả lụa thủ công.",
        "food_type": "Ăn Nhanh",
        "type": "Món Chính"
      },
      {
        "name": "Bánh Mì Heo Quay",
        "image": "assets/img/banh_mi_heo_quay.png",
        "price": 30000.0,
        "rate": "4.9",
        "category": "Bánh Mì",
        "description": "Bánh mì heo quay da giòn rụm, béo ngậy.",
        "food_type": "Ăn Nhanh",
        "type": "Món Chính"
      },
      {
        "name": "Cơm Tấm Sườn Bì",
        "image": "assets/img/com_tam_suon_bi.png",
        "price": 45000.0,
        "rate": "4.7",
        "category": "Cơm",
        "description": "Cơm tấm dẻo thơm, sườn nướng mềm ngọt.",
        "food_type": "Món Cơm",
        "type": "Món Chính"
      },
      {
        "name": "Cơm Tấm Chả Trứng",
        "image": "assets/img/com_tam.png",
        "price": 35000.0,
        "rate": "4.5",
        "category": "Cơm",
        "description": "Cơm tấm với chả trứng hấp thơm lừng.",
        "food_type": "Món Cơm",
        "type": "Món Chính"
      },
      {
        "name": "Cơm Gà Xối Mỡ",
        "image": "assets/img/com_ga.png",
        "price": 40000.0,
        "rate": "4.8",
        "category": "Cơm",
        "description": "Cơm gà xối mỡ da giòn rụm, thịt mọng nước.",
        "food_type": "Món Cơm",
        "type": "Món Chính"
      },
      {
        "name": "Bún Chả Hà Nội",
        "image": "assets/img/bun_cha.png",
        "price": 50000.0,
        "rate": "4.9",
        "category": "Bún",
        "description": "Bún chả chuẩn vị Hà Nội với thịt nướng than hoa.",
        "food_type": "Món Nước",
        "type": "Món Chính"
      },
      {
        "name": "Bún Bò Huế",
        "image": "assets/img/bun_bo_hue.png",
        "price": 55000.0,
        "rate": "4.8",
        "category": "Bún",
        "description": "Bún bò đậm đà hương vị miền Trung.",
        "food_type": "Món Nước",
        "type": "Món Chính"
      },
      {
        "name": "Bún Thịt Nướng",
        "image": "assets/img/bun_thit_nuong.png",
        "price": 40000.0,
        "rate": "4.7",
        "category": "Bún",
        "description": "Bún thịt nướng với nước mắm chua ngọt đặc trưng.",
        "food_type": "Món Trộn",
        "type": "Món Chính"
      },
    ];
    for (var food in foods) {
      await db.insert("foods", food);
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
        "%\$keyword%",
        "%\$keyword%",
        "%\$keyword%",
        "%\$keyword%",
      ],
      orderBy: "id DESC",
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
  }) async {
    final db = await instance.database;

    final oldItems = await db.query(
      "cart",
      where: "name = ?",
      whereArgs: [name],
    );

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

  // --- Admin User Management ---
  Future<int> updateUser(int id, {required String name, required String phone, required String address, required String role}) async {
    final db = await instance.database;
    return await db.update(
      "users",
      {
        "name": name,
        "phone": phone,
        "address": address,
        "role": role,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete("users", where: "id = ?", whereArgs: [id]);
  }

  // --- Admin Food Management ---
  Future<int> insertFood(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert("foods", data);
  }

  Future<int> updateFood(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update("foods", data, where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteFood(int id) async {
    final db = await instance.database;
    return await db.delete("foods", where: "id = ?", whereArgs: [id]);
  }

  // --- Admin Stats (Orders) ---
  Future<List<Map<String, dynamic>>> getCompletedOrders() async {
    final db = await instance.database;
    return await db.query("orders", where: "status = ?", whereArgs: ["Thành công"]);
  }
  
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await instance.database;
    return await db.query("orders", orderBy: "id DESC");
  }

  // --- Reviews Management ---
  Future<int> insertReview({required int orderId, required String userEmail, required int rating, required String comment}) async {
    final db = await instance.database;
    return await db.insert("reviews", {
      "order_id": orderId,
      "user_email": userEmail,
      "rating": rating,
      "comment": comment,
      "is_hidden": 0,
      "created_at": DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllReviews() async {
    final db = await instance.database;
    return await db.query("reviews", orderBy: "id DESC");
  }

  Future<int> updateReviewVisibility(int id, int isHidden) async {
    final db = await instance.database;
    return await db.update("reviews", {"is_hidden": isHidden}, where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteReview(int id) async {
    final db = await instance.database;
    return await db.delete("reviews", where: "id = ?", whereArgs: [id]);
  }

  Future<int> updateOrderReviewStatus(int orderId, int isReviewed) async {
    final db = await instance.database;
    return await db.update("orders", {"is_reviewed": isReviewed}, where: "id = ?", whereArgs: [orderId]);
  }

  // --- Category Management ---
  Future<int> insertCategory(Map<String, dynamic> data) async {
    final db = await instance.database;
    if (!data.containsKey('created_at')) {
      data['created_at'] = DateTime.now().toIso8601String();
    }
    return await db.insert("categories", data);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await instance.database;
    return await db.query("categories", orderBy: "id DESC");
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete("categories", where: "id = ?", whereArgs: [id]);
  }

  // --- Offer Management ---
  Future<int> insertOffer(Map<String, dynamic> data) async {
    final db = await instance.database;
    if (!data.containsKey('created_at')) {
      data['created_at'] = DateTime.now().toIso8601String();
    }
    return await db.insert("offers", data);
  }

  Future<List<Map<String, dynamic>>> getOffers() async {
    final db = await instance.database;
    return await db.query("offers", orderBy: "id DESC");
  }

  Future<int> updateOffer(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update("offers", data, where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteOffer(int id) async {
    final db = await instance.database;
    return await db.delete("offers", where: "id = ?", whereArgs: [id]);
  }

  Future<int> insertUsedOffer(int userId, int offerId) async {
    final db = await instance.database;
    return await db.insert(
      "user_used_offers",
      {
        "user_id": userId,
        "offer_id": offerId,
        "created_at": DateTime.now().toIso8601String(),
      },
    );
  }

  Future<bool> checkOfferUsed(int userId, int offerId) async {
    final db = await instance.database;
    final result = await db.query(
      "user_used_offers",
      where: "user_id = ? AND offer_id = ?",
      whereArgs: [userId, offerId],
    );
    return result.isNotEmpty;
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }

}