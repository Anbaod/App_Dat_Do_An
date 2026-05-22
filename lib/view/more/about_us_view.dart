import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';

import 'my_order_view.dart';

class AboutUsView extends StatefulWidget {
  const AboutUsView({super.key});

  @override
  State<AboutUsView> createState() => _AboutUsViewState();
}

class _AboutUsViewState extends State<AboutUsView> {
  List aboutTextArr = [
    "Chào mừng bạn đến với FastFood, ứng dụng đặt đồ ăn nhanh hàng đầu tại Việt Nam, mang đến cho bạn hàng nghìn lựa chọn món ăn ngon từ burger, pizza, mì ý cho đến đồ uống mát lạnh và đồ tráng miệng ngọt ngào.",
    "Chúng tôi cam kết cung cấp dịch vụ đặt món nhanh chóng, giao hàng siêu tốc trong vòng 30 phút để đảm bảo món ăn luôn nóng hổi và giữ trọn hương vị tươi ngon khi đến tay khách hàng.",
    "Mỗi nhà hàng và món ăn trên hệ thống đều được tuyển chọn kỹ lưỡng, đảm bảo quy trình vệ sinh an toàn thực phẩm khắt khe và chất lượng nguyên liệu đạt chuẩn cao nhất.",
    "Với giao diện thân thiện, tính năng thông minh giúp tìm kiếm món ăn dễ dàng cùng hàng loạt chương trình ưu đãi hấp dẫn, FastFood sẽ mang đến cho bạn trải nghiệm ẩm thực trọn vẹn và tuyệt vời.",
    "Đội ngũ hỗ trợ khách hàng của chúng tôi luôn sẵn sàng phục vụ 24/7 để giải quyết nhanh chóng mọi thắc mắc và đảm bảo sự hài lòng tuyệt đối của bạn trong mỗi chuyến hành trình ẩm thực.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        "Về chúng tôi",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyOrderView()));
                      },
                      icon: Image.asset(
                        "assets/img/shopping_cart.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: aboutTextArr.length,
               
                itemBuilder: ((context, index) {
                  var txt = aboutTextArr[index] as String? ?? "";
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 25),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: TColor.primary,
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Text(
                            txt,
                            style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
