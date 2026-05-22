import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import '../../database/db_helper.dart';

class AdminOrderManagementView extends StatefulWidget {
  const AdminOrderManagementView({super.key});

  @override
  State<AdminOrderManagementView> createState() => _AdminOrderManagementViewState();
}

class _AdminOrderManagementViewState extends State<AdminOrderManagementView> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  final List<String> statuses = [
    "Chờ xác nhận",
    "Đã xác nhận",
    "Đang chuẩn bị",
    "Đang giao",
    "Thành công"
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final data = await DBHelper.instance.getOrders();
    setState(() {
      orders = data;
      isLoading = false;
    });
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    await DBHelper.instance.updateOrderStatus(orderId, newStatus);
    _loadOrders();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã cập nhật trạng thái đơn hàng thành: $newStatus")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Đơn hàng", style: TextStyle(color: Colors.white)),
        backgroundColor: TColor.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("Chưa có đơn hàng nào"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final o = orders[index];
                    final currentStatus = o['status'] ?? "Chờ xác nhận";
                    
                    // Validate status just in case it doesn't exist in the list
                    String validStatus = statuses.contains(currentStatus) 
                        ? currentStatus 
                        : "Chờ xác nhận";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Đơn hàng #${o['id']}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: TColor.primaryText),
                                ),
                                Text(
                                  "${o['total']} VNĐ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: TColor.primary),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text("Ngày đặt: ${o['created_at']?.toString().substring(0, 16) ?? 'N/A'}"),
                            Text("Địa chỉ: ${o['address']}"),
                            Text("Thanh toán: ${o['payment_method']}"),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Trạng thái:", style: TextStyle(fontWeight: FontWeight.bold)),
                                DropdownButton<String>(
                                  value: validStatus,
                                  items: statuses.map((status) {
                                    return DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(
                                        status, 
                                        style: TextStyle(
                                          color: status == "Thành công" 
                                              ? Colors.green 
                                              : (status == "Đang giao" ? Colors.blue : Colors.orange)
                                        )
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newVal) {
                                    if (newVal != null && newVal != currentStatus) {
                                      _updateStatus(o['id'], newVal);
                                    }
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
