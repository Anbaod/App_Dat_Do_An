import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/database/db_helper.dart';

class AdminReviewManagementView extends StatefulWidget {
  const AdminReviewManagementView({super.key});

  @override
  State<AdminReviewManagementView> createState() => _AdminReviewManagementViewState();
}

class _AdminReviewManagementViewState extends State<AdminReviewManagementView> {
  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final data = await DBHelper.instance.getAllReviews();
    setState(() {
      reviews = data;
    });
  }

  void _toggleVisibility(int id, int currentStatus) async {
    await DBHelper.instance.updateReviewVisibility(id, currentStatus == 0 ? 1 : 0);
    _loadReviews();
  }

  void _deleteReview(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa đánh giá này vĩnh viễn?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              await DBHelper.instance.deleteReview(id);
              Navigator.pop(context);
              _loadReviews();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Đánh giá", style: TextStyle(color: Colors.white)),
        backgroundColor: TColor.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: reviews.isEmpty
          ? const Center(child: Text("Chưa có đánh giá nào"))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final r = reviews[index];
                bool isHidden = r['is_hidden'] == 1;

                return Card(
                  color: isHidden ? Colors.grey.shade200 : Colors.white,
                  child: ListTile(
                    title: Row(
                      children: [
                        Text("${r['rating']} ⭐", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        const SizedBox(width: 10),
                        Text(r['user_email'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(r['comment'] ?? ""),
                        if (isHidden) const Text("(Đã bị ẩn)", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility, color: isHidden ? Colors.grey : Colors.blue),
                          onPressed: () => _toggleVisibility(r['id'], r['is_hidden']),
                          tooltip: isHidden ? "Hiện đánh giá" : "Ẩn đánh giá",
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReview(r['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
