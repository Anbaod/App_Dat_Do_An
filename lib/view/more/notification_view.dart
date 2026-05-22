import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';

import 'my_order_view.dart';
import '../../common_widget/cart_button.dart';

import '../../database/db_helper.dart';
import 'package:intl/intl.dart';

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
    final data = await DBHelper.instance.getNotifications();
    setState(() {
      notificationArr = List<Map<String, dynamic>>.from(data);
      isLoading = false;
    });
  }

  String formatTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('HH:mm dd/MM/yyyy').format(date);
    } catch (e) {
      return isoString;
    }
  }

  int get unreadCount {
    return notificationArr.where((item) => item["is_read"] == 0).length;
  }

  Future<void> markAsRead(int index) async {
    int id = notificationArr[index]["id"];
    await DBHelper.instance.markNotificationRead(id);
    await loadNotifications();
  }

  Future<void> markAllRead() async {
    await DBHelper.instance.markAllNotificationsRead();
    await loadNotifications();
  }

  Future<void> deleteNotification(int index) async {
    int id = notificationArr[index]["id"];
    await DBHelper.instance.deleteNotification(id);
    await loadNotifications();
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
          const CartButton(),
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
                final bool isRead = item["is_read"] == 1;

                return Dismissible(
                  key: ValueKey(item["id"].toString()),
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
                                  Icons.notifications,
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
                                const SizedBox(height: 8),
                                Text(
                                  formatTime(item["created_at"]),
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