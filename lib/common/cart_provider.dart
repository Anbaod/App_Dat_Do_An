import 'package:flutter/foundation.dart';
import 'package:food_delivery/model/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount {
    int count = 0;
    for (var item in _items) {
      count += item.qty;
    }
    return count;
  }

  bool get isEmpty => _items.isEmpty;

  double get subTotal {
    double total = 0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  double get deliveryCost => _items.isEmpty ? 0 : 2.0;

  double get discount => subTotal > 10 ? 4.0 : 0.0;

  double get total => subTotal + deliveryCost - discount;

  void addToCart(CartItem newItem) {
    for (var item in _items) {
      if (item.isSameItem(newItem)) {
        item.qty += newItem.qty;
        notifyListeners();
        return;
      }
    }
    _items.add(newItem);
    notifyListeners();
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void updateQty(int index, int newQty) {
    if (index >= 0 && index < _items.length) {
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].qty = newQty;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
