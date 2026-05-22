import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';

import 'package:food_delivery/database/db_helper.dart';
import 'checkout_view.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({super.key});

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  double get subTotal {
    double sum = 0;
    for (var item in cartItems) {
      double price = double.tryParse(item["price"]?.toString() ?? "0") ?? 0;
      int qty = int.tryParse(item["qty"]?.toString() ?? "1") ?? 1;
      sum += price * qty;
    }
    return sum;
  }

  double get deliveryCost => cartItems.isEmpty ? 0.0 : 2.0;
  double get discount => cartItems.isEmpty ? 0.0 : 4.0;
  double get total => (subTotal + deliveryCost - discount).clamp(0.0, double.infinity);

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    setState(() {
      isLoading = true;
    });
    final items = await DBHelper.instance.getCart();
    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  Future<void> updateQty(int id, int currentQty, int delta) async {
    int newQty = currentQty + delta;
    await DBHelper.instance.updateCartQty(id, newQty);
    await loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 46),
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Giỏ hàng của tôi",
                              style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (cartItems.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 80,
                                color: TColor.secondaryText.withOpacity(0.5),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                "Giỏ hàng của bạn đang trống",
                                style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      Container(
                        decoration: BoxDecoration(color: TColor.textfield),
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: cartItems.length,
                          separatorBuilder: ((context, index) => Divider(
                                indent: 25,
                                endIndent: 25,
                                color: TColor.secondaryText.withOpacity(0.5),
                                height: 1,
                              )),
                          itemBuilder: ((context, index) {
                            var cObj = cartItems[index];
                            double itemPrice = double.tryParse(cObj["price"]?.toString() ?? "0") ?? 0;
                            int itemQty = int.tryParse(cObj["qty"]?.toString() ?? "1") ?? 1;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 25),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cObj["name"].toString(),
                                          style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "\$${itemPrice.toStringAsFixed(2)} / phần",
                                          style: TextStyle(
                                              color: TColor.secondaryText,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    icon: Icon(Icons.remove_circle_outline,
                                        color: TColor.primary, size: 22),
                                    onPressed: () {
                                      int id = int.tryParse(cObj["id"]?.toString() ?? "0") ?? 0;
                                      updateQty(id, itemQty, -1);
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    itemQty.toString(),
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    icon: Icon(Icons.add_circle_outline,
                                        color: TColor.primary, size: 22),
                                    onPressed: () {
                                      int id = int.tryParse(cObj["id"]?.toString() ?? "0") ?? 0;
                                      updateQty(id, itemQty, 1);
                                    },
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    "\$${(itemPrice * itemQty).toStringAsFixed(2)}",
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent, size: 22),
                                    onPressed: () async {
                                      int id = int.tryParse(cObj["id"]?.toString() ?? "0") ?? 0;
                                      await DBHelper.instance.deleteCartItem(id);
                                      await loadCart();
                                    },
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Ghi chú giao hàng",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.add, color: TColor.primary),
                                  label: Text(
                                    "Thêm ghi chú",
                                    style: TextStyle(
                                        color: TColor.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              color: TColor.secondaryText.withOpacity(0.5),
                              height: 1,
                            ),
                            const SizedBox(height: 15),
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
                                  "\$${subTotal.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: TColor.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
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
                                  "\$${deliveryCost.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: TColor.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Giảm giá",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  "-\$${discount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: TColor.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
                            Divider(
                              color: TColor.secondaryText.withOpacity(0.5),
                              height: 1,
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tổng tiền",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  "\$${total.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: TColor.primary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                            const SizedBox(height: 25),
                            RoundButton(
                              title: "Thanh toán",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CheckoutView(),
                                  ),
                                ).then((_) {
                                  // Khi quay lại từ trang Checkout, tải lại giỏ hàng
                                  loadCart();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
    );
  }
}
