import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../more/my_order_view.dart';
import 'menu_items_view.dart';
import '../../database/db_helper.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  TextEditingController txtSearch = TextEditingController();

  List<Map<String, dynamic>> menuArr = [
    {
      "name": "Food",
      "image": "assets/img/menu_1.png",
      "items_count": "0",
    },
    {
      "name": "Beverages",
      "image": "assets/img/menu_2.png",
      "items_count": "0",
    },
    {
      "name": "Desserts",
      "image": "assets/img/menu_3.png",
      "items_count": "0",
    },
    {
      "name": "Promotions",
      "image": "assets/img/menu_4.png",
      "items_count": "0",
    },
  ];

  List<Map<String, dynamic>> filteredMenu = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    filteredMenu = menuArr;
    loadCategoryCounts();
  }

  Future<void> loadCategoryCounts() async {
    try {
      final List<Map<String, dynamic>> updatedMenu = [];
      for (var item in menuArr) {
        final categoryName = item["name"].toString();
        final db = await DBHelper.instance.database;
        final countResult = Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM foods WHERE category = ?", [categoryName]),
        ) ?? 0;

        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(item);
        updatedItem["items_count"] = countResult.toString();
        updatedMenu.add(updatedItem);
      }

      setState(() {
        menuArr = updatedMenu;
        searchMenu(txtSearch.text);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading category counts: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchMenu(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        filteredMenu = menuArr;
      } else {
        filteredMenu = menuArr.where((item) {
          return item["name"]
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 180),
            width: media.width * 0.27,
            height: media.height * 0.6,
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 46),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Thực đơn",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
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
                      hintText: "Tìm danh mục món ăn",
                      controller: txtSearch,
                      onChanged: searchMenu,
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

                  const SizedBox(height: 30),

                  isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : filteredMenu.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.all(30),
                        child: Text(
                          "Không tìm thấy danh mục",
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 15,
                          ),
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 20,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredMenu.length,
                        itemBuilder: (context, index) {
                          var mObj = filteredMenu[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MenuItemsView(
                                    mObj: mObj,
                                  ),
                                ),
                              ).then((_) {
                                loadCategoryCounts();
                              });
                            },
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                    right: 20,
                                  ),
                                  width: media.width - 100,
                                  height: 90,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      bottomLeft: Radius.circular(25),
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 7,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),

                                Row(
                                  children: [
                                    Image.asset(
                                      mObj["image"].toString(),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                    ),

                                    const SizedBox(width: 15),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mObj["name"].toString(),
                                            style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            "${mObj["items_count"]} món",
                                            style: TextStyle(
                                              color: TColor.secondaryText,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(17.5),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        "assets/img/btn_next.png",
                                        width: 15,
                                        height: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}