import 'package:flutter/material.dart';
import 'package:food_delivery/view/more/about_us_view.dart';
import 'package:food_delivery/view/more/inbox_view.dart';
import 'package:food_delivery/view/more/payment_details_view.dart';

import '../../common/color_extension.dart';
import 'notification_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/welcome_view.dart';
import 'order_history_view.dart';
import 'my_pending_orders_view.dart';
import '../../common_widget/cart_button.dart';

class MoreView extends StatefulWidget {
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  List moreArr = [
    {
      "index": "1",
      "name": "Phương thức thanh toán",
      "image": "assets/img/more_payment.png",
      "base": 0
    },
    {
      "index": "2",
      "name": "Đơn hàng của tôi",
      "image": "assets/img/more_my_order.png",
      "base": 0
    },
    {
      "index": "3",
      "name": "Thông báo",
      "image": "assets/img/more_notification.png",
      "base": 15
    },
    {
      "index": "4",
      "name": "Hộp thư thoại",
      "image": "assets/img/more_inbox.png",
      "base": 0
    },
    {
      "index": "5",
      "name": "Về chúng tôi",
      "image": "assets/img/more_info.png",
      "base": 0
    },
    {
      "index": "6",
      "name": "Đang xử lý",
      "image": "assets/img/more_my_order.png",
      "base": 0
    },
    {
      "index": "7",
      "name": "Đăng xuất",
      "icon": Icons.logout,
      "base": 0
    },
  ];

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
                      "Khác",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    const CartButton(),
                  ],
                ),
              ),
              ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: moreArr.length,
                  itemBuilder: (context, index) {
                    var mObj = moreArr[index] as Map? ?? {};
                    var countBase = mObj["base"] as int? ?? 0;
                    return InkWell(
                      onTap: () async {
                        switch (mObj["index"].toString()) {
                          case "1":
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PaymentDetailsView()));
                            break;

                          case "2":
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const OrderHistoryView()));
                            break;
                          case "3":
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationsView()));
                            break;
                          case "4":
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const InboxView()));
                            break;
                          case "5":
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AboutUsView()));
                            break;
                          case "6":
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyPendingOrdersView()));
                            break;
                          case "7":
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove("user_login");

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WelcomeView(),
                              ),
                                  (route) => false,
                            );
                            break;

                          default:
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                              decoration: BoxDecoration(
                                  color: TColor.textfield,
                                  borderRadius: BorderRadius.circular(5)),
                              margin: const EdgeInsets.only(right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: TColor.placeholder,
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    alignment: Alignment.center,
                                    child: mObj["image"] != null
                                        ? Image.asset(mObj["image"].toString(),
                                            width: 25,
                                            height: 25,
                                            fit: BoxFit.contain)
                                        : Icon(
                                            mObj["icon"] as IconData?,
                                            color: TColor.primaryText,
                                            size: 25,
                                          ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Text(
                                      mObj["name"].toString(),
                                      style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  if (countBase > 0)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(12.5)),
                                      alignment: Alignment.center,
                                      child: Text(
                                        countBase.toString(),
                                        style: TextStyle(
                                            color: TColor.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: TColor.textfield,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Image.asset("assets/img/btn_next.png",
                                  width: 10,
                                  height: 10,
                                  color: TColor.primaryText),
                            ),
                          ],
                        ),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
