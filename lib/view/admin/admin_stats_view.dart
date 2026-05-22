import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/database/db_helper.dart';

class AdminStatsView extends StatefulWidget {
  const AdminStatsView({super.key});

  @override
  State<AdminStatsView> createState() => _AdminStatsViewState();
}

class _AdminStatsViewState extends State<AdminStatsView> {
  double totalRevenue = 0;
  int completedOrdersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final orders = await DBHelper.instance.getCompletedOrders();
    double revenue = 0;
    for (var o in orders) {
      revenue += (o['total'] ?? 0) as double;
    }
    setState(() {
      completedOrdersCount = orders.length;
      totalRevenue = revenue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê Doanh thu", style: TextStyle(color: Colors.white)),
        backgroundColor: TColor.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatCard("Doanh thu Tổng", "$totalRevenue VNĐ", Icons.monetization_on, Colors.green),
            const SizedBox(height: 20),
            _buildStatCard("Đơn hàng Thành công", "$completedOrdersCount đơn", Icons.shopping_bag, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: TColor.secondaryText, fontSize: 16)),
                const SizedBox(height: 5),
                Text(value, style: TextStyle(color: TColor.primaryText, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
