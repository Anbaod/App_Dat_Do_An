import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';
import 'package:food_delivery/database/db_helper.dart';

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

  List<Map<String, dynamic>> categoryItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  Future<void> loadFoods() async {
    final String category = widget.mObj["name"]?.toString() ?? "Food";
    try {
      final items = await DBHelper.instance.getFoodsByCategory(category);
      setState(() {
        categoryItems = items;
        filteredItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Lỗi tải thực đơn từ SQLite: $e");
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                                      builder: (context) => ItemDetailsView(
                                        mObj: mObj,
                                      ),
                                    ),
                                  ).then((_) {
                                    // reload in case favorite status was toggled
                                    loadFoods();
                                  });
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