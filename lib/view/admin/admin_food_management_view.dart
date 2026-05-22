import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/database/db_helper.dart';

class AdminFoodManagementView extends StatefulWidget {
  const AdminFoodManagementView({super.key});

  @override
  State<AdminFoodManagementView> createState() => _AdminFoodManagementViewState();
}

class _AdminFoodManagementViewState extends State<AdminFoodManagementView> {
  List<Map<String, dynamic>> foods = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await DBHelper.instance.database;
    final foodData = await db.query("foods", orderBy: "id DESC");
    final categoryData = await DBHelper.instance.getCategories();
    
    setState(() {
      foods = foodData;
      categories = categoryData;
      isLoading = false;
    });
  }

  void _showFoodForm([Map<String, dynamic>? food]) {
    final nameCtrl = TextEditingController(text: food?['name']);
    final imageCtrl = TextEditingController(text: food?['image']);
    final priceCtrl = TextEditingController(text: food?['price']?.toString());
    final descCtrl = TextEditingController(text: food?['description']);
    String? selectedCategory = food?['category'];
    
    // Đảm bảo selectedCategory nằm trong danh sách categories
    if (selectedCategory != null && !categories.any((c) => c['name'] == selectedCategory)) {
      selectedCategory = null;
    }
    // Gán mặc định nếu rỗng
    if (selectedCategory == null && categories.isNotEmpty) {
      selectedCategory = categories.first['name'];
    }

    final isEdit = food != null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEdit ? "Sửa món ăn" : "Thêm món mới"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên món")),
                    TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Giá (VNĐ)"), keyboardType: TextInputType.number),
                    TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: "Đường dẫn ảnh (assets/img/...)")),
                    
                    if (categories.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(labelText: "Danh mục"),
                        items: categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat['name'],
                            child: Text(cat['name']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setStateDialog(() {
                            selectedCategory = val;
                          });
                        },
                      ),
                      
                    TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Mô tả"), maxLines: 2),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
                ElevatedButton(
                  onPressed: () async {
                    final data = {
                      "name": nameCtrl.text,
                      "price": double.tryParse(priceCtrl.text) ?? 0.0,
                      "image": imageCtrl.text,
                      "description": descCtrl.text,
                      "rate": food?['rate'] ?? "4.9",
                      "rating": food?['rating'] ?? "124",
                      "type": food?['type'] ?? "Food",
                      "food_type": food?['food_type'] ?? "Fast Food",
                      "category": selectedCategory ?? "Food"
                    };

                    if (isEdit) {
                      await DBHelper.instance.updateFood(food['id'], data);
                    } else {
                      await DBHelper.instance.insertFood(data);
                    }

                    if (mounted) Navigator.pop(context);
                    _loadData();
                  },
                  child: const Text("Lưu"),
                )
              ],
            );
          }
        );
      },
    );
  }

  void _deleteFood(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa món này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              await DBHelper.instance.deleteFood(id);
              if (mounted) Navigator.pop(context);
              _loadData();
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
        title: const Text("Quản lý Món ăn", style: TextStyle(color: Colors.white)),
        backgroundColor: TColor.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColor.primary,
        onPressed: () => _showFoodForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : foods.isEmpty 
          ? const Center(child: Text("Chưa có món ăn nào. Hãy thêm mới!"))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final f = foods[index];
                return Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 50, height: 50,
                      child: Image.asset(f['image'].toString(), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood)),
                    ),
                    title: Text(f['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${f['price']} VNĐ\nDanh mục: ${f['category'] ?? 'Không rõ'}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showFoodForm(f)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteFood(f['id'])),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
