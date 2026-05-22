import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/database/db_helper.dart';

import 'my_order_view.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<Map<String, dynamic>> notificationArr = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final list = await DBHelper.instance.getNotifications();
      setState(() {
        notificationArr = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Lỗi tải thông báo: $e");
    }
  }

  int get unreadCount {
    return notificationArr.where((item) => (item["is_read"] as int? ?? 0) == 0).length;
  }

  Future<void> markAsRead(int index) async {
    final item = notificationArr[index];
    final id = item["id"] as int?;
    if (id != null) {
      try {
        await DBHelper.instance.markNotificationRead(id);
        loadNotifications();
      } catch (e) {
        debugPrint("Lỗi đánh dấu đã đọc: $e");
      }
    }
  }

  Future<void> markAllRead() async {
    try {
      await DBHelper.instance.markAllNotificationsRead();
      loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã đánh dấu đọc tất cả thông báo")),
        );
      }
    } catch (e) {
      debugPrint("Lỗi đánh dấu đọc tất cả: $e");
    }
  }

  Future<void> deleteNotification(int index) async {
    final item = notificationArr[index];
    final id = item["id"] as int?;
    if (id != null) {
      try {
        await DBHelper.instance.deleteNotification(id);
        loadNotifications();
      } catch (e) {
        debugPrint("Lỗi xóa thông báo: $e");
      }
    }
  }

  String formatTime(String? dateStr) {
    if (dateStr == null) return "";
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) {
      return "Vừa xong";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} phút trước";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} giờ trước";
    } else {
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.day}/${dt.month}/${dt.year}";
    }
  }

  IconData getNotificationIcon(String title, String message) {
    final t = "${title.toLowerCase()} ${message.toLowerCase()}";
    if (t.contains("đơn hàng") || t.contains("order") || t.contains("đặt hàng")) {
      return Icons.receipt_long;
    } else if (t.contains("giao") || t.contains("shipping") || t.contains("tài xế") || t.contains("driver")) {
      return Icons.delivery_dining;
    } else if (t.contains("thành công") || t.contains("hoàn thành") || t.contains("success")) {
      return Icons.check_circle;
    } else if (t.contains("chuẩn bị") || t.contains("nấu") || t.contains("cooking")) {
      return Icons.restaurant;
    }
    return Icons.notifications;
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
          "Thông báo",
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
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationArr.isEmpty
              ? Center(
                  child: Text(
                    "Không có thông báo nào",
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
                              "Bạn có $unreadCount thông báo chưa đọc",
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
                        itemCount: notificationArr.length,
                        itemBuilder: (context, index) {
                          final item = notificationArr[index];
                          final bool isRead = (item["is_read"] as int? ?? 0) == 1;
                          final String title = item["title"]?.toString() ?? "Thông báo";
                          final String message = item["message"]?.toString() ?? "";
                          final String timeStr = formatTime(item["created_at"]?.toString());
                          final IconData iconData = getNotificationIcon(title, message);

                          return Dismissible(
                            key: ValueKey(item["id"]?.toString() ?? index.toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              deleteNotification(index);
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
                                markAsRead(index);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: isRead ? TColor.white : TColor.textfield,
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
                                            iconData,
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
                                            title,
                                            style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 15,
                                              fontWeight: isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.w800,
                                            ),
                                          ),
                                          if (message.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              message,
                                              style: TextStyle(
                                                color: TColor.secondaryText,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Text(
                                            timeStr,
                                            style: TextStyle(
                                              color: TColor.secondaryText,
                                              fontSize: 12,
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