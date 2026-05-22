import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';

class CartCounter {
  static final ValueNotifier<int> count = ValueNotifier<int>(0);

  static Future<void> updateCount() async {
    try {
      final db = await DBHelper.instance.database;
      final result = await db.rawQuery("SELECT SUM(qty) FROM cart");
      final totalQty = Sqflite.firstIntValue(result) ?? 0;
      count.value = totalQty;
    } catch (e) {
      debugPrint("Error updating cart count: $e");
    }
  }
}
