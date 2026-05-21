import 'package:flutter/material.dart';
import 'package:food_delivery/common/cart_provider.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:provider/provider.dart';

import 'checkout_view.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({super.key});

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return _buildEmptyCart();
          }
          return _buildCartContent(cart);
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "My Order",
                    style: TextStyle(
                        color: TColor.primaryText, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: TColor.secondaryText),
                  const SizedBox(height: 20),
                  Text(
                    "Giỏ hàng của bạn đang trống",
                    style: TextStyle(
                        color: TColor.secondaryText, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hãy thêm món ăn yêu thích vào giỏ hàng",
                    style: TextStyle(color: TColor.secondaryText, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(CartProvider cart) {
    return SingleChildScrollView(
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
                    onPressed: () => Navigator.pop(context),
                    icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "My Order",
                      style: TextStyle(
                          color: TColor.primaryText, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: TColor.textfield),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: cart.items.length,
                separatorBuilder: (context, index) => Divider(
                  indent: 25,
                  endIndent: 25,
                  color: TColor.secondaryText.withOpacity(0.5),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  var item = cart.items[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                              if (item.size != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    "Size: ${item.size}",
                                    style: TextStyle(color: TColor.secondaryText, fontSize: 11),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                cart.updateQty(index, item.qty - 1);
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: TColor.primary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.remove, color: Colors.white, size: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                item.qty.toString(),
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                cart.updateQty(index, item.qty + 1);
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: TColor.primary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.add, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 15),
                        SizedBox(
                          width: 60,
                          child: Text(
                            "\$${item.totalPrice.toStringAsFixed(2)}",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Sub Total",
                          style: TextStyle(
                              color: TColor.primaryText, fontSize: 13, fontWeight: FontWeight.w700)),
                      Text("\$${cart.subTotal.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: TColor.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Delivery Cost",
                          style: TextStyle(
                              color: TColor.primaryText, fontSize: 13, fontWeight: FontWeight.w700)),
                      Text("\$${cart.deliveryCost.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: TColor.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Discount",
                          style: TextStyle(
                              color: TColor.primaryText, fontSize: 13, fontWeight: FontWeight.w700)),
                      Text("-\$${cart.discount.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: TColor.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Divider(color: TColor.secondaryText.withOpacity(0.5), height: 1),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total",
                          style: TextStyle(
                              color: TColor.primaryText, fontSize: 13, fontWeight: FontWeight.w700)),
                      Text("\$${cart.total.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: TColor.primary, fontSize: 22, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  RoundButton(
                    title: "Checkout",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CheckoutView()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
