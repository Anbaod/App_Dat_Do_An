import 'package:flutter/material.dart';
import 'package:food_delivery/common_widget/round_button.dart';

import '../../common/color_extension.dart';
import '../main_tabview/main_tabview.dart';
import 'my_pending_orders_view.dart';

class CheckoutMessageView extends StatefulWidget {
  const CheckoutMessageView({super.key});

  @override
  State<CheckoutMessageView> createState() => _CheckoutMessageViewState();
}

class _CheckoutMessageViewState extends State<CheckoutMessageView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return  Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        width: media.width,
        decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: TColor.primaryText,
                    size: 25,
                  ),
                )
              ],
            ),
            Image.asset(
              "assets/img/thank_you.png",
              width: media.width * 0.55,
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              "Cảm ơn bạn!",
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 26,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              "đã đặt hàng",
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              "Đơn hàng của bạn đang được xử lý. Chúng tôi sẽ thông báo cho bạn khi đơn hàng được giao đi. Bạn có thể kiểm tra trạng thái đơn hàng của mình",
              textAlign: TextAlign.center,
              style: TextStyle(color: TColor.primaryText, fontSize: 14),
            ),
            const SizedBox(
              height: 35,
            ),
            RoundButton(
              title: "Theo dõi đơn hàng", 
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainTabView()),
                  (route) => false,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPendingOrdersView()),
                );
              }
            ),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainTabView()),
                  (route) => false,
                );
              },
              child: Text(
                "Về trang chủ",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      
    );
  }
}
