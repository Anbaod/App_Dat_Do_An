import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';

import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common_widget/category_cell.dart';
import '../../common_widget/most_popular_cell.dart';
import 'package:food_delivery/database/db_helper.dart';
import 'package:food_delivery/view/menu/menu_items_view.dart';

import '../../common_widget/cart_button.dart';
import '../../common/cart_counter.dart';
import '../menu/item_details_view.dart';
import '../../common_widget/recent_item_row.dart';
import '../../common_widget/popular_resutaurant_row.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<Map<String, dynamic>> catArr = [];
  List<Map<String, dynamic>> mostPopArr = [];
  List<Map<String, dynamic>> recentArr = [];
  List<Map<String, dynamic>> searchArr = [];
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    txtSearch.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final categories = await DBHelper.instance.getCategories();
    final db = await DBHelper.instance.database;
    final allFoods = await db.query("foods");

    // Lấy 4 danh mục đầu
    List<Map<String, dynamic>> topCats = [];
    for (int i = 0; i < categories.length && i < 4; i++) {
      topCats.add(categories[i]);
    }

    List<Map<String, dynamic>> foods = List<Map<String, dynamic>>.from(allFoods);
    
    setState(() {
      catArr = topCats;
      mostPopArr = foods.skip(3).take(4).toList(); // Lấy các món phổ biến
      recentArr = foods.skip(1).take(4).toList(); // Lấy các món ăn gần đây
      isLoading = false;
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        isSearching = false;
        searchArr = [];
      });
    } else {
      final results = await DBHelper.instance.searchFoods(query.trim());
      setState(() {
        isSearching = true;
        searchArr = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 46,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Chào buổi sáng ${ServiceCall.userPayload[KKey.name] ?? ""}!",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    const CartButton(),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundTextfield(
                  key: const ValueKey("txtHomeSearch"),
                  hintText: "Tìm món ăn",
                  controller: txtSearch,
                  focusNode: _searchFocus,
                  onChanged: _search,
                  left: Container(
                    alignment: Alignment.center,
                    width: 30,
                    child: Image.asset(
                      "assets/img/search.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                  right: txtSearch.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            txtSearch.clear();
                            _search("");
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(
                height: 30,
              ),

              if (isSearching) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Kết quả tìm kiếm cho '${txtSearch.text}'",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                searchArr.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            "Không tìm thấy món ăn nào",
                            style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: searchArr.length,
                        itemBuilder: ((context, index) {
                          var sObj = searchArr[index] as Map? ?? {};
                          return RecentItemRow(
                            rObj: sObj,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailsView(mObj: sObj),
                                ),
                              ).then((_) {
                                CartCounter.updateCount();
                              });
                            },
                          );
                        }),
                      ),
              ] else ...[
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: catArr.length,
                    itemBuilder: ((context, index) {
                      var cObj = catArr[index] as Map? ?? {};
                      return CategoryCell(
                        cObj: cObj,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MenuItemsView(
                                        mObj: {"name": cObj["name"].toString()},
                                      )));
                        },
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Được yêu thích nhất",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: mostPopArr.length,
                    itemBuilder: ((context, index) {
                      var mObj = mostPopArr[index] as Map? ?? {};
                      return MostPopularCell(
                        mObj: mObj,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailsView(mObj: mObj),
                            ),
                          ).then((_) {
                            CartCounter.updateCount();
                          });
                        },
                      );
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Món ăn gần đây",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: recentArr.length,
                  itemBuilder: ((context, index) {
                    var rObj = recentArr[index] as Map? ?? {};
                    return PopularRestaurantRow(
                      pObj: rObj,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsView(mObj: rObj),
                          ),
                        ).then((_) {
                          CartCounter.updateCount();
                        });
                      },
                    );
                  }),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
