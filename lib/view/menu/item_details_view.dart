import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_delivery/common_widget/round_icon_button.dart';

import '../../common/color_extension.dart';
import '../../common/format_utils.dart';
import '../../database/db_helper.dart';
import '../more/my_order_view.dart';

class ItemDetailsView extends StatefulWidget {
  final Map mObj;

  const ItemDetailsView({
    super.key,
    required this.mObj,
  });

  @override
  State<ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<ItemDetailsView> {
  double price = 15;
  int qty = 1;
  bool isFav = false;

  late String image;
  late String name;
  late String type;
  late String foodType;
  late String rate;
  late String description;

  String? selectedSize;
  String? selectedIngredient;

  @override
  void initState() {
    super.initState();

    image = widget.mObj["image"]?.toString() ?? "assets/img/detail_top.png";
    name = widget.mObj["name"]?.toString() ?? "Món ăn";
    type = widget.mObj["type"]?.toString() ?? "Food";
    foodType = widget.mObj["food_type"]?.toString() ?? "Fast Food";
    rate = widget.mObj["rate"]?.toString() ?? "4.5";
    description = widget.mObj["description"]?.toString() ??
        "Món ăn thơm ngon, được chuẩn bị từ nguyên liệu tươi và phù hợp cho mọi bữa ăn.";

    price = double.tryParse(widget.mObj["price"]?.toString() ?? "15") ?? 15;
  }

  void addToCart() async {
    await DBHelper.instance.insertCart(
      name: name,
      image: image,
      price: price,
      qty: qty,
    );
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã thêm $qty x $name vào giỏ hàng"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.asset(
            image,
            width: media.width,
            height: media.width,
            fit: BoxFit.cover,
          ),

          Container(
            width: media.width,
            height: media.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.transparent,
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: media.width - 60,
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: TColor.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 35),

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "$type • $foodType",
                                style: TextStyle(
                                  color: TColor.secondaryText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      IgnorePointer(
                                        ignoring: true,
                                        child: RatingBar.builder(
                                          initialRating:
                                          double.tryParse(rate) ?? 4,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 20,
                                          itemPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 1.0,
                                          ),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: TColor.primary,
                                          ),
                                          onRatingUpdate: (rating) {},
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "$rate sao",
                                        style: TextStyle(
                                          color: TColor.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${price.toStringAsFixed(0)} VNĐ",
                                        style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 31,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "/phần",
                                        style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "Mô tả",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                description,
                                style: TextStyle(
                                  color: TColor.secondaryText,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 25),
                              child: Divider(
                                color: TColor.secondaryText.withOpacity(0.4),
                                height: 1,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "Tùy chỉnh đơn hàng",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 25),
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  color: TColor.textfield,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedSize,
                                    items: ["Nhỏ", "Vừa", "Lớn"].map((e) {
                                      return DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: TextStyle(
                                            color: TColor.primaryText,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        selectedSize = val;
                                      });
                                    },
                                    hint: Text(
                                      "- Chọn kích thước -",
                                      style: TextStyle(
                                        color: TColor.secondaryText,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 25),
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  color: TColor.textfield,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedIngredient,
                                    items: [
                                      "Không thêm",
                                      "Thêm phô mai",
                                      "Thêm sốt",
                                      "Thêm rau",
                                    ].map((e) {
                                      return DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: TextStyle(
                                            color: TColor.primaryText,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        selectedIngredient = val;
                                      });
                                    },
                                    hint: Text(
                                      "- Chọn nguyên liệu thêm -",
                                      style: TextStyle(
                                        color: TColor.secondaryText,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                children: [
                                  Text(
                                    "Số lượng",
                                    style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  const Spacer(),

                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        qty--;
                                        if (qty < 1) qty = 1;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      height: 25,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: TColor.primary,
                                        borderRadius:
                                        BorderRadius.circular(12.5),
                                      ),
                                      child: Text(
                                        "-",
                                        style: TextStyle(
                                          color: TColor.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    height: 25,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: TColor.primary,
                                      ),
                                      borderRadius: BorderRadius.circular(12.5),
                                    ),
                                    child: Text(
                                      qty.toString(),
                                      style: TextStyle(
                                        color: TColor.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        qty++;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      height: 25,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: TColor.primary,
                                        borderRadius:
                                        BorderRadius.circular(12.5),
                                      ),
                                      child: Text(
                                        "+",
                                        style: TextStyle(
                                          color: TColor.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                              height: 220,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Container(
                                    width: media.width * 0.25,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: TColor.primary,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(35),
                                        bottomRight: Radius.circular(35),
                                      ),
                                    ),
                                  ),

                                  Center(
                                    child: Stack(
                                      alignment: Alignment.centerRight,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 10,
                                            right: 20,
                                          ),
                                          width: media.width - 80,
                                          height: 120,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(35),
                                              bottomLeft: Radius.circular(35),
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 12,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Tổng tiền",
                                                style: TextStyle(
                                                  color: TColor.primaryText,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),

                                              const SizedBox(height: 15),

                                              Text(
                                                FormatUtils.formatVND(price * qty),
                                                style: TextStyle(
                                                  color: TColor.primaryText,
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),

                                              const SizedBox(height: 15),

                                              SizedBox(
                                                width: 150,
                                                height: 28,
                                                child: RoundIconButton(
                                                  title: "Thêm vào giỏ",
                                                  icon:
                                                  "assets/img/shopping_add.png",
                                                  color: TColor.primary,
                                                  onPressed: addToCart,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                const MyOrderView(),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(22.5),
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
                                              "assets/img/shopping_cart.png",
                                              width: 20,
                                              height: 20,
                                              color: TColor.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),

                  Container(
                    height: media.width - 20,
                    alignment: Alignment.bottomRight,
                    margin: const EdgeInsets.only(right: 4),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isFav = !isFav;
                        });
                      },
                      child: Image.asset(
                        isFav
                            ? "assets/img/favorites_btn.png"
                            : "assets/img/favorites_btn_2.png",
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 35),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.asset(
                          "assets/img/btn_back.png",
                          width: 20,
                          height: 20,
                          color: TColor.white,
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
                          color: TColor.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}