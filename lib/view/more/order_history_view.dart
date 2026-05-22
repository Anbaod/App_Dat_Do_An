import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/view/more/review_order_view.dart';
import '../../database/db_helper.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    orders = await DBHelper.instance.getOrders();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteOrder(int id) async {
    await DBHelper.instance.deleteOrder(id);
    await loadOrders();
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
          "Lịch sử đơn hàng",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(
        child: Text(
          "Chưa có đơn hàng nào",
          style: TextStyle(
            color: TColor.secondaryText,
            fontSize: 16,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: TColor.textfield,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Đơn hàng #${order["id"]}",
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Địa chỉ: ${order["address"]}",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Thanh toán: ${order["payment_method"]}",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Tổng tiền: ${order["total"]} VNĐ",
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Ngày đặt: ${order["created_at"]}",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Trạng thái: ${order["status"]}",
                  style: TextStyle(
                    color: order["status"] == "Thành công" ? Colors.green : Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order["status"] == "Thành công" && order["is_reviewed"] == 0)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewOrderView(orderId: order["id"]),
                            ),
                          );
                          loadOrders();
                        },
                        icon: const Icon(Icons.star, color: Colors.white, size: 18),
                        label: const Text("Đánh giá"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (order["status"] == "Thành công" && order["is_reviewed"] == 1)
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text("Đã đánh giá", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        deleteOrder(order["id"]);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      label: const Text(
                        "Xóa",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}