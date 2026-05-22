import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/format_utils.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/common/cart_counter.dart';

import 'package:food_delivery/database/db_helper.dart';
import 'checkout_view.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({super.key});

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  List<Map<String, dynamic>> itemArr = [];
  double subTotal = 0;
  double deliveryCost = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final data = await DBHelper.instance.getCart();
    double total = 0;
    for (var item in data) {
      total += (double.tryParse(item['price'].toString()) ?? 0.0) * (item['qty'] ?? 0);
    }
    setState(() {
      itemArr = data;
      subTotal = total;
      deliveryCost = itemArr.isNotEmpty ? 20000.0 : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 46,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset("assets/img/btn_back.png",
                          width: 20, height: 20),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        "Giỏ hàng",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: itemArr.length,
                  separatorBuilder: ((context, index) => Divider(
                        indent: 25,
                        endIndent: 25,
                        color: TColor.secondaryText.withOpacity(0.5),
                        height: 1,
                      )),
                  itemBuilder: ((context, index) {
                    var cObj = itemArr[index] as Map? ?? {};
                    int currentQty = cObj["qty"] ?? 1;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              cObj["image"]?.toString() ?? "assets/img/menu_1.png",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.fastfood, color: TColor.secondaryText),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cObj["name"].toString(),
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  FormatUtils.formatVND(double.parse(cObj["price"].toString())),
                                  style: TextStyle(
                                      color: TColor.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: currentQty <= 1
                                    ? null
                                    : () async {
                                        int newQty = currentQty - 1;
                                        await DBHelper.instance.updateCartQty(cObj["id"], newQty);
                                        await CartCounter.updateCount();
                                        _loadCart();
                                      },
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: currentQty <= 1
                                        ? Colors.grey.shade300
                                        : TColor.primary,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currentQty.toString(),
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  int newQty = currentQty + 1;
                                  await DBHelper.instance.updateCartQty(cObj["id"], newQty);
                                  await CartCounter.updateCount();
                                  _loadCart();
                                },
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: TColor.primary,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () async {
                              await DBHelper.instance.deleteCartItem(cObj["id"]);
                              await CartCounter.updateCount();
                              _loadCart();
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade400,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tạm tính",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          FormatUtils.formatVND(subTotal),
                          style: TextStyle(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Phí giao hàng",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          FormatUtils.formatVND(deliveryCost),
                          style: TextStyle(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Divider(
                      color: TColor.secondaryText.withOpacity(0.5),
                      height: 1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tổng cộng",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          FormatUtils.formatVND(subTotal + deliveryCost),
                          style: TextStyle(
                              color: TColor.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    RoundButton(
                      title: "Thanh toán",
                      onPressed: () {
                        if (itemArr.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Giỏ hàng đang trống!")),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutView(
                              cartItems: itemArr,
                              subTotal: subTotal,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
