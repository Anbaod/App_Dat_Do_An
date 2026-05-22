import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';
import 'package:provider/provider.dart';
import '../../common/cart_provider.dart';

import '../../common_widget/menu_item_row.dart';
import '../more/my_order_view.dart';
import 'item_details_view.dart';

class MenuItemsView extends StatefulWidget {
  final Map mObj;

  const MenuItemsView({
    super.key,
    required this.mObj,
  });

  @override
  State<MenuItemsView> createState() => _MenuItemsViewState();
}

class _MenuItemsViewState extends State<MenuItemsView> {
  TextEditingController txtSearch = TextEditingController();

  List<Map<String, dynamic>> allItems = [
    {
      "category": "Food",
      "image": "assets/img/menu_1.png",
      "name": "Beef Burger",
      "rate": "4.9",
      "rating": "124",
      "type": "Minute by tuk tuk",
      "food_type": "Desserts",
      "price": 12.0
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
      "category": "Beverages",
      "image": "assets/img/offer_1.png",
      "name": "Cà Phê Sữa Đá",
      "rate": "4.9",
      "rating": "124",
      "type": "Cakes by Tella",
      "food_type": "Desserts",
      "price": 18.0
    },
    {
      "category": "Beverages",
      "image": "assets/img/dess_3.png",
      "name": "Street Shake",
      "rate": "4.7",
      "rating": "86",
      "type": "Café Racer",
      "food_type": "Desserts",
      "price": 8.0
    },
    {
      "category": "Beverages",
      "image": "assets/img/menu_3.png",
      "name": "Trà Sữa Trân Châu",
      "rate": "4.9",
      "rating": "124",
      "type": "Minute by tuk tuk",
      "food_type": "Desserts",
      "price": 14.0
    },

    {
      "category": "Desserts",
      "image": "assets/img/dess_1.png",
      "name": "French Apple Pie",
      "rate": "4.9",
      "rating": "124",
      "type": "Minute by tuk tuk",
      "food_type": "Desserts",
      "price": 12.0
    },
    {
      "category": "Desserts",
      "image": "assets/img/dess_2.png",
      "name": "Dark Chocolate Cake",
      "rate": "4.8",
      "rating": "98",
      "type": "Cakes by Tella",
      "food_type": "Desserts",
      "price": 18.0
    },
    {
      "category": "Desserts",
      "image": "assets/img/dess_4.png",
      "name": "Fudgy Chewy Brownies",
      "rate": "4.9",
      "rating": "124",
      "type": "Café Racer",
      "food_type": "Desserts",
      "price": 8.0
    },

    {
      "category": "Promotions",
      "image": "assets/img/offer_1.png",
      "name": "Café de Noires",
      "rate": "4.9",
      "rating": "124",
      "type": "Minute by tuk tuk",
      "food_type": "Desserts",
      "price": 14.0
    },
  ];

  List<Map<String, dynamic>> categoryItems = [];
  List<Map<String, dynamic>> filteredItems = [];

  @override
  void initState() {
    super.initState();

    final String category = widget.mObj["name"]?.toString() ?? "Food";

    categoryItems = allItems.where((item) {
      return item["category"]?.toString() == category;
    }).toList();

    filteredItems = categoryItems;
  }

  void searchFood(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        filteredItems = categoryItems;
        return;
      }

      final keyword = value.toLowerCase().trim();

      filteredItems = categoryItems.where((item) {
        final name = item["name"]?.toString().toLowerCase() ?? "";
        final type = item["type"]?.toString().toLowerCase() ?? "";
        final foodType = item["food_type"]?.toString().toLowerCase() ?? "";

        return name.contains(keyword) ||
            type.contains(keyword) ||
            foodType.contains(keyword);
      }).toList();
    });
  }

  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.mObj["name"]?.toString() ?? "Món ăn";

    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 46),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset(
                        "assets/img/btn_back.png",
                        width: 20,
                        height: 20,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyOrderView(),
                                  ),
                                );
                              },
                              icon: Image.asset(
                                "assets/img/shopping_cart.png",
                                width: 25,
                                height: 25,
                              ),
                            ),
                            if (cart.itemCount > 0)
                              Positioned(
                                right: 5,
                                top: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    cart.itemCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundTextfield(
                  hintText: "Tìm món ăn",
                  controller: txtSearch,
                  onChanged: searchFood,
                  left: Container(
                    alignment: Alignment.center,
                    width: 30,
                    child: Image.asset(
                      "assets/img/search.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              filteredItems.isEmpty
                  ? Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  "Không tìm thấy món ăn",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 15,
                  ),
                ),
              )
                  : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  var mObj = filteredItems[index];

                  return MenuItemRow(
                    mObj: mObj,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemDetailsView(itemObj: mObj)),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}