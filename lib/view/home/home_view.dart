import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';

import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common_widget/category_cell.dart';
import '../../common_widget/most_popular_cell.dart';
import '../../common_widget/popular_resutaurant_row.dart';
import '../../common_widget/recent_item_row.dart';
import '../../common_widget/view_all_title_row.dart';
import '../more/my_order_view.dart';
import '../menu/menu_items_view.dart';
import '../menu/item_details_view.dart';
import '../../database/db_helper.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();

  List catArr = [
    {"name": "Food", "image": "assets/img/menu_1.png"},
    {"name": "Beverages", "image": "assets/img/menu_2.png"},
    {"name": "Desserts", "image": "assets/img/menu_3.png"},
    {"name": "Promotions", "image": "assets/img/menu_4.png"},
  ];

  List popArr = [];
  List mostPopArr = [];
  List recentArr = [];
  List searchResultArr = [];

  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      final allFoods = await DBHelper.instance.getFoods();
      setState(() {
        // Popular: items with rating >= 4.8, limit 3
        popArr = allFoods
            .where((f) => double.tryParse(f["rate"]?.toString() ?? "0.0")! >= 4.8)
            .take(3)
            .toList();

        // Most Popular: rate >= 4.7, skip 3, limit 4
        mostPopArr = allFoods
            .where((f) => double.tryParse(f["rate"]?.toString() ?? "0.0")! >= 4.7)
            .skip(3)
            .take(4)
            .toList();
        if (mostPopArr.isEmpty) {
          mostPopArr = allFoods.take(2).toList();
        }

        // Recent: take 4
        recentArr = allFoods.take(4).toList();
        
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error loading home data: $e");
    }
  }

  void searchFoods(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        isSearching = false;
        searchResultArr = [];
      });
      return;
    }

    try {
      final results = await DBHelper.instance.searchFoods(query);
      setState(() {
        isSearching = true;
        searchResultArr = results;
      });
    } catch (e) {
      debugPrint("Error searching foods: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      "Good morning ${ServiceCall.userPayload[KKey.name] ?? ""}!",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyOrderView()));
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
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivering to",
                      style:
                          TextStyle(color: TColor.secondaryText, fontSize: 11),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Current Location",
                          style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        Image.asset(
                          "assets/img/dropdown.png",
                          width: 12,
                          height: 12,
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundTextfield(
                  hintText: "Search Food",
                  controller: txtSearch,
                  onChanged: searchFoods,
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
              const SizedBox(
                height: 30,
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (isSearching) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Search Results (${searchResultArr.length})",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w800),
                      ),
                      TextButton(
                        onPressed: () {
                          txtSearch.clear();
                          setState(() {
                            isSearching = false;
                            searchResultArr = [];
                          });
                        },
                        child: Text(
                          "Clear",
                          style: TextStyle(
                              color: TColor.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                searchResultArr.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            "No foods found matching your query",
                            style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 16),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: searchResultArr.length,
                        itemBuilder: ((context, index) {
                          var rObj = searchResultArr[index] as Map? ?? {};
                          return RecentItemRow(
                            rObj: rObj,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailsView(mObj: rObj),
                                ),
                              );
                            },
                          );
                        }),
                      )
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
                              builder: (context) => MenuItemsView(mObj: cObj),
                            ),
                          ).then((_) {
                            loadHomeData();
                          });
                        },
                      );
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ViewAllTitleRow(
                    title: "Popular Restaurants",
                    onView: () {},
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: popArr.length,
                  itemBuilder: ((context, index) {
                    var pObj = popArr[index] as Map? ?? {};
                    return PopularRestaurantRow(
                      pObj: pObj,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsView(mObj: pObj),
                          ),
                        ).then((_) {
                          loadHomeData();
                        });
                      },
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ViewAllTitleRow(
                    title: "Most Popular",
                    onView: () {},
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
                            loadHomeData();
                          });
                        },
                      );
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ViewAllTitleRow(
                    title: "Recent Items",
                    onView: () {},
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: recentArr.length,
                  itemBuilder: ((context, index) {
                    var rObj = recentArr[index] as Map? ?? {};
                    return RecentItemRow(
                      rObj: rObj,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsView(mObj: rObj),
                          ),
                        ).then((_) {
                          loadHomeData();
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
