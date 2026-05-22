import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import '../../database/db_helper.dart';

class AdminOfferManagementView extends StatefulWidget {
  const AdminOfferManagementView({super.key});

  @override
  State<AdminOfferManagementView> createState() => _AdminOfferManagementViewState();
}

class _AdminOfferManagementViewState extends State<AdminOfferManagementView> {
  List<Map<String, dynamic>> offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    final data = await DBHelper.instance.getOffers();
    setState(() {
      offers = data;
      isLoading = false;
    });
  }

  void _deleteOffer(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc chắn muốn xóa ưu đãi này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DBHelper.instance.deleteOffer(id);
              _loadOffers();
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showOfferDialog([Map<String, dynamic>? offer]) {
    showDialog(
      context: context,
      builder: (context) => _OfferDialog(
        offer: offer,
        onSave: _loadOffers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Ưu đãi", style: TextStyle(color: Colors.white)),
        backgroundColor: TColor.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : offers.isEmpty
              ? const Center(child: Text("Chưa có ưu đãi nào"))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final o = offers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: Image.asset(o['image'] ?? "assets/img/offer_1.png", width: 50, height: 50, fit: BoxFit.contain),
                        title: Text(o['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${o['discount']} (Giá gốc: ${o['price']} VNĐ)", style: TextStyle(color: TColor.primary, fontWeight: FontWeight.bold)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showOfferDialog(o),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteOffer(o['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showOfferDialog,
        backgroundColor: TColor.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _OfferDialog extends StatefulWidget {
  final Map<String, dynamic>? offer;
  final VoidCallback onSave;

  const _OfferDialog({
    super.key,
    this.offer,
    required this.onSave,
  });

  @override
  State<_OfferDialog> createState() => _OfferDialogState();
}

class _OfferDialogState extends State<_OfferDialog> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> allFoods = [];
  List<Map<String, dynamic>> filteredFoods = [];

  String? selectedCategory;
  Map<String, dynamic>? selectedFood;
  String selectedDiscountType = "Giảm 10%";
  
  final List<String> discountOptions = [
    "Giảm 10%",
    "Giảm 20%",
    "Giảm 30%",
    "Giảm 50%",
    "Mua 1 tặng 1",
    "Freeship"
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await DBHelper.instance.database;
    final catData = await DBHelper.instance.getCategories();
    final foodData = await db.query("foods", orderBy: "name ASC");

    setState(() {
      categories = catData;
      allFoods = foodData;
      isLoading = false;

      if (widget.offer != null) {
        selectedDiscountType = widget.offer!['discount'] ?? "Giảm 10%";
        // Find category from food name
        final foodName = widget.offer!['name'];
        final foodMatch = allFoods.where((f) => f['name'] == foodName).toList();
        if (foodMatch.isNotEmpty) {
          selectedFood = foodMatch.first;
          selectedCategory = selectedFood!['category'];
          _filterFoods();
        }
      } else if (categories.isNotEmpty) {
        selectedCategory = categories.first['name'];
        _filterFoods();
      }
    });
  }

  void _filterFoods() {
    if (selectedCategory != null) {
      filteredFoods = allFoods.where((f) => f['category'] == selectedCategory).toList();
      if (filteredFoods.isNotEmpty) {
        selectedFood = filteredFoods.first;
      } else {
        selectedFood = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.offer != null ? "Sửa ưu đãi" : "Thêm ưu đãi mới"),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (categories.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: "Chọn danh mục"),
                      items: categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['name'],
                          child: Text(cat['name']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCategory = val;
                          _filterFoods();
                        });
                      },
                    )
                  else
                    const Text("Chưa có danh mục nào", style: TextStyle(color: Colors.red)),
                  
                  const SizedBox(height: 15),

                  if (filteredFoods.isNotEmpty)
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: selectedFood,
                      decoration: const InputDecoration(labelText: "Chọn sản phẩm"),
                      items: filteredFoods.map((f) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: f,
                          child: Text(f['name']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedFood = val;
                        });
                      },
                    )
                  else
                    const Text("Không có sản phẩm nào trong danh mục này", style: TextStyle(color: Colors.red)),

                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    value: selectedDiscountType,
                    decoration: const InputDecoration(labelText: "Loại khuyến mãi"),
                    items: discountOptions.map((d) {
                      return DropdownMenuItem<String>(
                        value: d,
                        child: Text(d),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        if (val != null) {
                          selectedDiscountType = val;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: () async {
            if (selectedFood != null) {
              final data = {
                "name": selectedFood!['name'],
                "image": selectedFood!['image'] ?? "assets/img/offer_1.png",
                "discount": selectedDiscountType,
                "price": selectedFood!['price'] ?? 0.0,
                "type": selectedFood!['type'] ?? "Food",
                "food_type": selectedFood!['food_type'] ?? "Fast Food",
                "rate": selectedFood!['rate'] ?? "4.9",
              };
              if (widget.offer != null) {
                await DBHelper.instance.updateOffer(widget.offer!['id'], data);
              } else {
                await DBHelper.instance.insertOffer(data);
              }
              if (mounted) {
                Navigator.pop(context);
                widget.onSave();
              }
            }
          },
          child: const Text("Lưu"),
        ),
      ],
    );
  }
}
