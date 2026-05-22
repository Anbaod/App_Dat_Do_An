import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery/common/cart_provider.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/database/db_helper.dart';

import 'change_address_view.dart';
import 'checkout_message_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  List paymentArr = [
    {"name": "Thanh toán khi nhận hàng", "icon": "assets/img/cash.png"},
    {"name": "**** **** **** 2187", "icon": "assets/img/visa_icon.png"},
    {"name": "test@gmail.com", "icon": "assets/img/paypal.png"},
  ];

  int selectMethod = -1;

  String deliveryAddress = "Thủ Dầu Một\nBình Dương, Việt Nam";
  Future<void> _changeAddress() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangeAddressView(),
      ),
    );

    if (result != null) {
      setState(() {
        deliveryAddress = result["address"];
      });
    }
  }

  void _sendOrder() async {
    if (selectMethod == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn phương thức thanh toán"),
        ),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giỏ hàng của bạn đang trống"),
        ),
      );
      return;
    }

    // Convert CartItem to Map<String, dynamic> for insertOrderWithItems
    final orderItems = cart.items.map((item) => {
      "name": item.name,
      "image": item.image,
      "price": item.price,
      "qty": item.qty,
    }).toList();

    try {
      await DBHelper.instance.insertOrderWithItems(
        address: deliveryAddress,
        paymentMethod: paymentArr[selectMethod]["name"],
        total: cart.total,
        items: orderItems,
      );

      // Xóa giỏ hàng local SQLite
      cart.clearCart();

      if (mounted) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) {
            return const CheckoutMessageView();
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi khi đặt hàng: $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
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
                      icon: Image.asset(
                        "assets/img/btn_back.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Thanh toán",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Địa chỉ giao hàng",
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            deliveryAddress,
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: _changeAddress,
                          child: Text(
                            "Thay đổi",
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
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
                          "Phương thức thanh toán",
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.add, color: TColor.primary),
                          label: Text(
                            "Thêm thẻ",
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: paymentArr.length,
                      itemBuilder: (context, index) {
                        var pObj = paymentArr[index] as Map? ?? {};

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectMethod = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 15.0,
                            ),
                            decoration: BoxDecoration(
                              color: TColor.textfield,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: TColor.secondaryText.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  pObj["icon"].toString(),
                                  width: 50,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),

                                Expanded(
                                  child: Text(
                                    pObj["name"].toString(),
                                    style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                Icon(
                                  selectMethod == index
                                      ? Icons.radio_button_on
                                      : Icons.radio_button_off,
                                  color: TColor.primary,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    _buildPriceRow("Tạm tính", "\$${cart.subTotal.toStringAsFixed(2)}"),
                    const SizedBox(height: 8),

                    _buildPriceRow(
                        "Phí giao hàng", "\$${cart.deliveryCost.toStringAsFixed(2)}"),
                    const SizedBox(height: 8),

                    if (cart.discount > 0) ...[
                      _buildPriceRow("Giảm giá", "-\$${cart.discount.toStringAsFixed(2)}"),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 7),

                    Divider(
                      color: TColor.secondaryText.withOpacity(0.5),
                      height: 1,
                    ),

                    const SizedBox(height: 15),

                    _buildPriceRow(
                      "Tổng cộng",
                      "\$${cart.total.toStringAsFixed(2)}",
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),

              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                child: RoundButton(
                  title: "Đặt hàng",
                  onPressed: _sendOrder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String title, String price, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: isTotal ? 15 : 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}