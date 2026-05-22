import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';

import '../../database/db_helper.dart';
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

  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  double subTotal = 0;
  double deliveryCost = 0;
  double discount = 0;

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
    double sum = 0;
    for (var item in items) {
      double price = double.tryParse(item["price"]?.toString() ?? "0") ?? 0;
      int qty = int.tryParse(item["qty"]?.toString() ?? "1") ?? 1;
      sum += price * qty;
    }
    setState(() {
      cartItems = items;
      subTotal = sum;
      deliveryCost = items.isEmpty ? 0.0 : 2.0;
      discount = items.isEmpty ? 0.0 : 4.0;
      isLoading = false;
    });
  }

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

  Future<void> _sendOrder() async {
    if (selectMethod == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn phương thức thanh toán"),
        ),
      );
      return;
    }

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giỏ hàng của bạn trống, không thể thanh toán"),
        ),
      );
      return;
    }

    try {
      await DBHelper.instance.insertOrderWithItems(
        address: deliveryAddress,
        paymentMethod: paymentArr[selectMethod]["name"],
        total: total,
        items: cartItems,
      );

      // Xóa giỏ hàng sau khi đặt hàng thành công
      await DBHelper.instance.clearCart();

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
            content: Text("Đã xảy ra lỗi: $e"),
          ),
        );
      }
    }
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
                              var pObj = paymentArr[index];

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectMethod = index;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 15,
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
                        children: [
                          const SizedBox(height: 15),

                          _buildPriceRow("Tạm tính", "\$${subTotal.toStringAsFixed(2)}"),
                          const SizedBox(height: 8),

                          _buildPriceRow(
                              "Phí giao hàng", "\$${deliveryCost.toStringAsFixed(2)}"),
                          const SizedBox(height: 8),

                          _buildPriceRow("Giảm giá", "-\$${discount.toStringAsFixed(2)}"),
                          const SizedBox(height: 15),

                          Divider(
                            color: TColor.secondaryText.withOpacity(0.5),
                            height: 1,
                          ),

                          const SizedBox(height: 15),

                          _buildPriceRow(
                            "Tổng cộng",
                            "\$${total.toStringAsFixed(2)}",
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