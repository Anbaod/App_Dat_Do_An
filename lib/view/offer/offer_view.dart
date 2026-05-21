import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';

import '../../common_widget/popular_resutaurant_row.dart';
import '../more/my_order_view.dart';

class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  TextEditingController txtSearch = TextEditingController();

  List<Map<String, dynamic>> offerArr = [
    {
      "image": "assets/img/offer_1.png",
      "name": "Café de Noires",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafe",
      "food_type": "Western Food",
      "discount": "Giảm 20%",
    },
    {
      "image": "assets/img/offer_2.png",
      "name": "Isso",
      "rate": "4.8",
      "rating": "98",
      "type": "Cafe",
      "food_type": "Fast Food",
      "discount": "Mua 1 tặng 1",
    },
    {
      "image": "assets/img/offer_3.png",
      "name": "Cafe Beans",
      "rate": "4.7",
      "rating": "86",
      "type": "Cafe",
      "food_type": "Coffee",
      "discount": "Freeship",
    },
    {
      "name": "Beef Burger",
      "image": "assets/img/menu_1.png",
      "price": 16.0,
      "rate": "4.9",
      "rating": "120",
      "type": "Burger",
      "food_type": "Fast Food",
      "discount": "Giảm 15%",
    },
    {
      "name": "Classic Burger",
      "image": "assets/img/menu_2.png",
      "price": 14.0,
      "rate": "4.8",
      "rating": "95",
      "type": "Burger",
      "food_type": "Fast Food",
      "discount": "Freeship",
    },
    {
      "name": "Cheese Chicken Burger",
      "image": "assets/img/menu_3.png",
      "price": 17.0,
      "rate": "4.7",
      "rating": "88",
      "type": "Burger",
      "food_type": "Fast Food",
      "discount": "Giảm 10%",
    },
    {
      "name": "Chicken Legs Basket",
      "image": "assets/img/menu_1.png",
      "price": 15.0,
      "rate": "4.6",
      "rating": "76",
      "type": "Chicken",
      "food_type": "Fried Food",
      "discount": "Giảm 12%",
    },
    {
      "name": "French Fries Large",
      "image": "assets/img/menu_2.png",
      "price": 6.0,
      "rate": "4.5",
      "rating": "64",
      "type": "Snack",
      "food_type": "Fast Food",
      "discount": "Giảm 5%",
    },
    {
      "name": "Pizza Hải Sản",
      "image": "assets/img/menu_3.png",
      "price": 22.0,
      "rate": "4.8",
      "rating": "140",
      "type": "Pizza",
      "food_type": "Italian Food",
      "discount": "Mua 1 tặng 1",
    },
    {
      "name": "Mì Ý Bò Bằm",
      "image": "assets/img/menu_1.png",
      "price": 18.0,
      "rate": "4.7",
      "rating": "102",
      "type": "Pasta",
      "food_type": "Western Food",
      "discount": "Giảm 18%",
    },
    {
      "name": "Gà Rán Giòn Cay",
      "image": "assets/img/menu_2.png",
      "price": 13.0,
      "rate": "4.6",
      "rating": "89",
      "type": "Chicken",
      "food_type": "Fast Food",
      "discount": "Freeship",
    },
    {
      "name": "Trà Sữa Trân Châu",
      "image": "assets/img/menu_3.png",
      "price": 5.0,
      "rate": "4.9",
      "rating": "210",
      "type": "Drink",
      "food_type": "Beverage",
      "discount": "Giảm 20%",
    },
    {
      "name": "Cà Phê Sữa Đá",
      "image": "assets/img/menu_1.png",
      "price": 4.0,
      "rate": "4.8",
      "rating": "180",
      "type": "Drink",
      "food_type": "Coffee",
      "discount": "Giảm 10%",
    },
    {
      "name": "Bánh Mì Thịt Nướng",
      "image": "assets/img/menu_2.png",
      "price": 7.0,
      "rate": "4.7",
      "rating": "130",
      "type": "Vietnamese Food",
      "food_type": "Street Food",
      "discount": "Freeship",
    },
    {
      "name": "Cơm Gà Xối Mỡ",
      "image": "assets/img/menu_3.png",
      "price": 12.0,
      "rate": "4.6",
      "rating": "118",
      "type": "Rice",
      "food_type": "Vietnamese Food",
      "discount": "Giảm 15%",
    },
  ];

  List<Map<String, dynamic>> filteredOffers = [];

  @override
  void initState() {
    super.initState();
    filteredOffers = offerArr;
  }

  void searchOffer(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        filteredOffers = offerArr;
        return;
      }

      final keyword = value.toLowerCase().trim();

      filteredOffers = offerArr.where((item) {
        final name = item["name"]?.toString().toLowerCase() ?? "";
        final type = item["type"]?.toString().toLowerCase() ?? "";
        final foodType = item["food_type"]?.toString().toLowerCase() ?? "";
        final discount = item["discount"]?.toString().toLowerCase() ?? "";

        return name.contains(keyword) ||
            type.contains(keyword) ||
            foodType.contains(keyword) ||
            discount.contains(keyword);
      }).toList();
    });
  }

  void showOfferDetail(Map<String, dynamic> item) {
    final String image = item["image"]?.toString() ?? "assets/img/offer_1.png";
    final String name = item["name"]?.toString() ?? "Ưu đãi";
    final String discount = item["discount"]?.toString() ?? "Ưu đãi";
    final String rate = item["rate"]?.toString() ?? "4.5";
    final String foodType = item["food_type"]?.toString() ?? "Food";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  image,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "$foodType • $rate sao",
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                discount,
                style: TextStyle(
                  color: TColor.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              RoundButton(
                title: "Dùng ưu đãi",
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Đã chọn ưu đãi: $discount"),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,

      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        title: Text(
          "Ưu đãi mới nhất",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
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

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Tìm mã giảm giá, ưu đãi đặc biệt\nvà các món ăn hấp dẫn.",
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: txtSearch,
                onChanged: searchOffer,
                decoration: InputDecoration(
                  hintText: "Tìm ưu đãi hoặc nhà hàng...",
                  prefixIcon: Icon(
                    Icons.search,
                    color: TColor.secondaryText,
                  ),
                  suffixIcon: txtSearch.text.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      txtSearch.clear();
                      searchOffer("");
                    },
                    icon: const Icon(Icons.close),
                  )
                      : null,
                  filled: true,
                  fillColor: TColor.textfield,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Tìm thấy ${filteredOffers.length} ưu đãi",
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: TColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_offer,
                      color: TColor.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Hôm nay có ${offerArr.length} ưu đãi dành cho bạn",
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            filteredOffers.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Text(
                  "Không tìm thấy ưu đãi phù hợp",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 15,
                  ),
                ),
              ),
            )
                : ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: filteredOffers.length,
              itemBuilder: (context, index) {
                var pObj = filteredOffers[index];
                final String discount =
                    pObj["discount"]?.toString() ?? "Ưu đãi";

                return Stack(
                  children: [
                    PopularRestaurantRow(
                      pObj: pObj,
                      onTap: () {
                        showOfferDetail(pObj);
                      },
                    ),

                    Positioned(
                      top: 15,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: TColor.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          discount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}