import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/view/login/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_food_management_view.dart';
import 'admin_stats_view.dart';
import 'admin_review_management_view.dart';
import 'admin_category_management_view.dart';
import 'admin_user_management_view.dart';
import 'admin_order_management_view.dart';
import 'admin_offer_management_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}
class _AdminDashboardViewState extends State<AdminDashboardView> {
  String adminName = "Admin";

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString("current_user_name") ?? "Admin";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved preferences
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: TColor.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Xin chào, $adminName!",
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Chào mừng bạn đến với trang quản trị FastFood.",
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildDashboardCard(
                  icon: Icons.category,
                  title: "Quản lý\nDanh mục",
                  color: Colors.pink,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCategoryManagementView()));
                  },
                ),
                _buildDashboardCard(
                  icon: Icons.fastfood,
                  title: "Quản lý\nMón ăn",
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminFoodManagementView()));
                  },
                ),
                _buildDashboardCard(
                  icon: Icons.rate_review,
                  title: "Quản lý\nĐánh giá",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminReviewManagementView()));
                  },
                ),
                _buildDashboardCard(
                  icon: Icons.shopping_cart,
                  title: "Quản lý\nĐơn hàng",
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOrderManagementView()));
                  },
                ),
                _buildDashboardCard(
                  icon: Icons.people,
                  title: "Quản lý\nNgười dùng",
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminUserManagementView()));
                  },
                ),
                _buildDashboardCard(
                  icon: Icons.bar_chart,
                  title: "Thống kê\nDoanh thu",
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminStatsView()));
                  },
                ),
                _buildDashboardCard(
                  icon: Icons.local_offer,
                  title: "Quản lý\nƯu đãi",
                  color: Colors.deepOrange,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOfferManagementView()));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
