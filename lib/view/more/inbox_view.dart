import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';

import 'my_order_view.dart';
import '../../common_widget/cart_button.dart';

class InboxView extends StatefulWidget {
  const InboxView({super.key});

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  List<Map<String, dynamic>> inboxArr = [
    {
      "title": "Ưu đãi hôm nay",
      "detail": "Giảm 20% cho đơn hàng từ 100.000đ.",
      "time": "2 phút trước",
      "isRead": false,
      "icon": Icons.local_offer,
    },
    {
      "title": "Đơn hàng đang chuẩn bị",
      "detail": "Nhà hàng đang chuẩn bị món ăn của bạn.",
      "time": "15 phút trước",
      "isRead": false,
      "icon": Icons.restaurant,
    },
    {
      "title": "Thanh toán thành công",
      "detail": "Đơn hàng của bạn đã được thanh toán thành công.",
      "time": "1 giờ trước",
      "isRead": true,
      "icon": Icons.payment,
    },
    {
      "title": "Giao hàng thành công",
      "detail": "Đơn hàng đã được giao đến địa chỉ của bạn.",
      "time": "Hôm qua",
      "isRead": true,
      "icon": Icons.delivery_dining,
    },
  ];

  int get unreadCount {
    return inboxArr.where((item) => item["isRead"] == false).length;
  }

  void openMessage(int index) {
    setState(() {
      inboxArr[index]["isRead"] = true;
    });

    final item = inboxArr[index];

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: TColor.secondaryText.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: TColor.primary.withOpacity(0.12),
                    child: Icon(
                      item["icon"],
                      color: TColor.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item["title"],
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                item["time"],
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                item["detail"],
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        );
      },
    );
  }

  void deleteMessage(int index) {
    setState(() {
      inboxArr.removeAt(index);
    });
  }

  void markAllRead() {
    setState(() {
      for (var item in inboxArr) {
        item["isRead"] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,

      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset(
            "assets/img/btn_back.png",
            width: 20,
            height: 20,
          ),
        ),
        title: Text(
          "Hộp thư",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: markAllRead,
            icon: Icon(
              Icons.done_all,
              color: TColor.primary,
            ),
          ),
          const CartButton(),
        ],
      ),

      body: inboxArr.isEmpty
          ? Center(
        child: Text(
          "Không có tin nhắn nào",
          style: TextStyle(
            color: TColor.secondaryText,
            fontSize: 16,
          ),
        ),
      )
          : Column(
        children: [
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 5),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: TColor.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Bạn có $unreadCount tin nhắn chưa đọc",
                    style: TextStyle(
                      color: TColor.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: inboxArr.length,
              itemBuilder: (context, index) {
                final item = inboxArr[index];
                final bool isRead = item["isRead"];

                return Dismissible(
                  key: ValueKey(item["title"] + index.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    deleteMessage(index);
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      openMessage(index);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isRead
                            ? TColor.white
                            : TColor.textfield,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isRead
                              ? TColor.secondaryText.withOpacity(0.15)
                              : TColor.primary.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                TColor.primary.withOpacity(0.12),
                                child: Icon(
                                  item["icon"],
                                  color: TColor.primary,
                                ),
                              ),
                              if (!isRead)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: TColor.primary,
                                      borderRadius:
                                      BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["title"],
                                  style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 15,
                                    fontWeight: isRead
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item["detail"],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item["time"],
                                  style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: TColor.secondaryText,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}