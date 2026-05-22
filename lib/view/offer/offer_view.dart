import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';

import '../../common_widget/popular_resutaurant_row.dart';
import '../../database/db_helper.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../more/my_order_view.dart';

class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  TextEditingController txtSearch = TextEditingController();

  List<Map<String, dynamic>> offerArr = [];
  List<Map<String, dynamic>> filteredOffers = [];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    final data = await DBHelper.instance.getOffers();
    String? userIdStr = ServiceCall.userPayload["id"]?.toString();
    int userId = int.tryParse(userIdStr ?? "0") ?? 0;
    
    List<Map<String, dynamic>> availableOffers = [];
    if (userId > 0) {
      for (var offer in data) {
        bool isUsed = await DBHelper.instance.checkOfferUsed(userId, offer["id"] as int);
        if (!isUsed) {
          availableOffers.add(offer);
        }
      }
    } else {
      availableOffers = data;
    }

    if (mounted) {
      setState(() {
        offerArr = availableOffers;
        filteredOffers = availableOffers;
      });
    }
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
                onPressed: () async {
                  double originalPrice = double.tryParse(item["price"]?.toString() ?? "0") ?? 0.0;
                  double finalPrice = originalPrice;
                  
                  if (discount.contains("10%")) {
                    finalPrice = originalPrice * 0.9;
                  } else if (discount.contains("20%")) {
                    finalPrice = originalPrice * 0.8;
                  } else if (discount.contains("30%")) {
                    finalPrice = originalPrice * 0.7;
                  } else if (discount.contains("50%")) {
                    finalPrice = originalPrice * 0.5;
                  }

                  await DBHelper.instance.insertCart(
                    name: "$name ($discount)",
                    image: image,
                    price: finalPrice,
                    qty: 1,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Đã thêm $name vào giỏ hàng với giá ${finalPrice.toStringAsFixed(0)} VNĐ"),
                      ),
                    );
                  }
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