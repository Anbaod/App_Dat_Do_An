class CartItem {
  final String name;
  final double price;
  final String image;
  int qty;
  final String? size;
  final String? ingredients;

  CartItem({
    required this.name,
    required this.price,
    required this.image,
    this.qty = 1,
    this.size,
    this.ingredients,
  });

  double get totalPrice => price * qty;

  bool isSameItem(CartItem other) {
    return name == other.name && size == other.size;
  }
}
