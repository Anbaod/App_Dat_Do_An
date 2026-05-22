import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();

  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB("food_delivery.db");
    await _seedFoodsIfEmpty(_database!);
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 8,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _seedFoodsIfEmpty(Database db) async {
    final countResult = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM foods"),
    );
    if (countResult == 0) {
      final List<Map<String, dynamic>> defaultFoods = [
        // --- FOOD ---
        {
          "category": "Food",
          "image": "assets/img/menu_1.png",
          "name": "Beef Burger",
          "rate": "4.9",
          "rating": "124",
          "type": "King Burgers",
          "food_type": "Fast Food",
          "price": 16.0,
          "description": "Burger bò thơm ngon với phô mai, rau tươi và sốt đặc biệt.",
        },
        {
          "category": "Food",
          "image": "assets/img/menu_2.png",
          "name": "Classic Burger",
          "rate": "4.8",
          "rating": "98",
          "type": "King Burgers",
          "food_type": "Fast Food",
          "price": 14.0,
          "description": "Burger truyền thống dễ ăn, phù hợp cho mọi bữa ăn.",
        },
        {
          "category": "Food",
          "image": "assets/img/menu_3.png",
          "name": "Pizza Hải Sản",
          "rate": "4.7",
          "rating": "102",
          "type": "Pizza House",
          "food_type": "Pizza",
          "price": 22.0,
          "description": "Pizza hải sản với tôm, mực, phô mai và sốt cà chua.",
        },
        {
          "category": "Food",
          "image": "assets/img/menu_1.png",
          "name": "Mì Ý Bò Bằm",
          "rate": "4.7",
          "rating": "102",
          "type": "Pasta Italian",
          "food_type": "Western Food",
          "price": 18.0,
          "description": "Mì Ý xốt bò bằm đậm đà chuẩn vị Ý.",
        },
        {
          "category": "Food",
          "image": "assets/img/menu_2.png",
          "name": "Gà Rán Giòn Cay",
          "rate": "4.6",
          "rating": "89",
          "type": "Crispy Chicken",
          "food_type": "Fast Food",
          "price": 13.0,
          "description": "Gà rán giòn rụm, vị cay nồng đậm đà hấp dẫn.",
        },
        {
          "category": "Food",
          "image": "assets/img/menu_3.png",
          "name": "Cơm Gà Xối Mỡ",
          "rate": "4.6",
          "rating": "118",
          "type": "Rice House",
          "food_type": "Vietnamese Food",
          "price": 12.0,
          "description": "Cơm chiên tơi xốp kèm đùi gà chiên da giòn rụm béo ngậy.",
        },
        {
          "category": "Food",
          "image": "assets/img/menu_2.png",
          "name": "Bánh Mì Thịt Nướng",
          "rate": "4.7",
          "rating": "130",
          "type": "Banh Mi VN",
          "food_type": "Street Food",
          "price": 7.0,
          "description": "Bánh mì Việt Nam giòn tan nhân thịt nướng thơm lừng kèm rau chua.",
        },

        // --- BEVERAGES ---
        {
          "category": "Beverages",
          "image": "assets/img/offer_1.png",
          "name": "Cà Phê Sữa Đá",
          "rate": "4.9",
          "rating": "200",
          "type": "Cafe Việt",
          "food_type": "Beverages",
          "price": 5.0,
          "description": "Cà phê sữa đá đậm vị Việt Nam, thơm béo và tỉnh táo.",
        },
        {
          "category": "Beverages",
          "image": "assets/img/dess_3.png",
          "name": "Street Shake",
          "rate": "4.7",
          "rating": "86",
          "type": "Café Racer",
          "food_type": "Beverages",
          "price": 10.0,
          "description": "Đồ uống mát lạnh, béo nhẹ, thích hợp dùng kèm đồ ăn nhanh.",
        },
        {
          "category": "Beverages",
          "image": "assets/img/menu_3.png",
          "name": "Trà Sữa Trân Châu",
          "rate": "4.9",
          "rating": "210",
          "type": "Milk Tea",
          "food_type": "Drink",
          "price": 5.0,
          "description": "Trà sữa trân châu ngọt dịu, thơm béo và dễ uống.",
        },
        {
          "category": "Beverages",
          "image": "assets/img/offer_2.png",
          "name": "Nước Ép Cam Tươi",
          "rate": "4.8",
          "rating": "95",
          "type": "Fresh Juice",
          "food_type": "Drink",
          "price": 6.0,
          "description": "Nước ép cam nguyên chất 100%, giàu Vitamin C tự nhiên.",
        },
        {
          "category": "Beverages",
          "image": "assets/img/offer_3.png",
          "name": "Trà Đào Sả Đá",
          "rate": "4.7",
          "rating": "112",
          "type": "Tea House",
          "food_type": "Drink",
          "price": 5.5,
          "description": "Trà đào thơm ngát kết hợp sả tươi và miếng đào giòn ngọt.",
        },

        // --- DESSERTS ---
        {
          "category": "Desserts",
          "image": "assets/img/dess_1.png",
          "name": "French Apple Pie",
          "rate": "4.9",
          "rating": "124",
          "type": "Minute by tuk tuk",
          "food_type": "Desserts",
          "price": 15.0,
          "description": "Bánh táo thơm ngon, lớp vỏ giòn nhẹ và nhân táo ngọt dịu.",
        },
        {
          "category": "Desserts",
          "image": "assets/img/dess_2.png",
          "name": "Dark Chocolate Cake",
          "rate": "4.8",
          "rating": "98",
          "type": "Cakes by Tella",
          "food_type": "Desserts",
          "price": 18.0,
          "description": "Bánh socola đậm vị, mềm mịn và hấp dẫn.",
        },
        {
          "category": "Desserts",
          "image": "assets/img/dess_4.png",
          "name": "Fudgy Chewy Brownies",
          "rate": "4.9",
          "rating": "124",
          "type": "Minute by tuk tuk",
          "food_type": "Desserts",
          "price": 16.0,
          "description": "Brownies mềm dẻo, thơm mùi socola và ngọt hài hòa.",
        },
        {
          "category": "Desserts",
          "image": "assets/img/dess_1.png",
          "name": "Strawberry Mousse",
          "rate": "4.8",
          "rating": "75",
          "type": "Sweet Bakery",
          "food_type": "Desserts",
          "price": 12.0,
          "description": "Bánh mousse dâu tây ngọt mát, mềm mịn tan trong miệng.",
        },
        {
          "category": "Desserts",
          "image": "assets/img/dess_2.png",
          "name": "Tiramisu Cake",
          "rate": "4.9",
          "rating": "92",
          "type": "Italian Bakery",
          "food_type": "Desserts",
          "price": 14.5,
          "description": "Bánh tiramisu béo ngậy, đượm hương cà phê và rượu nhẹ nồng nàn.",
        },

        // --- PROMOTIONS ---
        {
          "category": "Promotions",
          "image": "assets/img/offer_1.png",
          "name": "Café de Noires",
          "rate": "4.9",
          "rating": "124",
          "type": "Cafe",
          "food_type": "Western Food",
          "price": 12.0,
          "description": "Ưu đãi đặc biệt cho đồ uống và món ăn nhẹ.",
        },
        {
          "category": "Promotions",
          "image": "assets/img/offer_2.png",
          "name": "Isso",
          "rate": "4.8",
          "rating": "98",
          "type": "Cafe",
          "food_type": "Fast Food",
          "price": 10.0,
          "description": "Khuyến mãi mua 1 tặng 1 trong hôm nay.",
        },
        {
          "category": "Promotions",
          "image": "assets/img/offer_3.png",
          "name": "Cafe Beans",
          "rate": "4.7",
          "rating": "86",
          "type": "Cafe",
          "food_type": "Coffee",
          "price": 8.0,
          "description": "Miễn phí giao hàng cho đơn từ 50.000đ.",
        },
        {
          "category": "Promotions",
          "image": "assets/img/menu_1.png",
          "name": "Combo Burger & Pepsi",
          "rate": "4.9",
          "rating": "115",
          "type": "King Combo",
          "food_type": "Fast Food",
          "price": 18.5,
          "description": "Combo Beef Burger và nước ngọt Pepsi mát lạnh.",
        },
        {
          "category": "Promotions",
          "image": "assets/img/menu_2.png",
          "name": "Combo Gà Rán Gia Đình",
          "rate": "4.8",
          "rating": "142",
          "type": "Family Combo",
          "food_type": "Fried Food",
          "price": 29.0,
          "description": "Combo 4 miếng gà rán giòn cay, khoai tây chiên cỡ lớn.",
        }
      ];

      for (var food in defaultFoods) {
        await db.insert("foods", food);
      }
    }
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

    if (oldVersion < 7) {
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

    if (oldVersion < 8) {
      try {
        await db.execute("DELETE FROM foods");
      } catch (_) {}
      await _seedFoodsIfEmpty(db);
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



  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}