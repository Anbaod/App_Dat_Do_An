import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import '../../database/db_helper.dart';

class AdminCategoryManagementView extends StatefulWidget {
  const AdminCategoryManagementView({super.key});

  @override
  State<AdminCategoryManagementView> createState() => _AdminCategoryManagementViewState();
}

class _AdminCategoryManagementViewState extends State<AdminCategoryManagementView> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await DBHelper.instance.getCategories();
    setState(() {
      categories = data;
      isLoading = false;
    });
  }

  void _deleteCategory(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc chắn muốn xóa danh mục này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DBHelper.instance.deleteCategory(id);
              _loadCategories();
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog() {
    final nameController = TextEditingController();
    final imageController = TextEditingController(text: "assets/img/cat_1.png");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm danh mục mới"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Tên danh mục"),
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: "Đường dẫn ảnh (assets/img/...)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await DBHelper.instance.insertCategory({
                  "name": nameController.text,
                  "image": imageController.text.isNotEmpty ? imageController.text : "assets/img/cat_1.png",
                });
                if (mounted) Navigator.pop(context);
                _loadCategories();
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Danh mục", style: TextStyle(color: Colors.white)),
        backgroundColor: TColor.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const Center(child: Text("Chưa có danh mục nào"))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final c = categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: Image.asset(c['image'] ?? "assets/img/cat_1.png", width: 50, height: 50, fit: BoxFit.contain),
                        title: Text(c['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(c['id']),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCategoryDialog,
        backgroundColor: TColor.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
