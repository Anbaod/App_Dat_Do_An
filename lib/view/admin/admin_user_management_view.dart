import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/database/db_helper.dart';

class AdminUserManagementView extends StatefulWidget {
  const AdminUserManagementView({super.key});

  @override
  State<AdminUserManagementView> createState() => _AdminUserManagementViewState();
}

class _AdminUserManagementViewState extends State<AdminUserManagementView> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final data = await DBHelper.instance.getUsers();
    setState(() {
      users = data;
    });
  }

  void _showEditDialog(Map<String, dynamic> user) {
    TextEditingController nameController = TextEditingController(text: user['name']);
    TextEditingController phoneController = TextEditingController(text: user['phone'] ?? "");
    TextEditingController addressController = TextEditingController(text: user['address'] ?? "");
    String role = user['role'] ?? 'user';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Sửa thông tin"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Tên"),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Số điện thoại"),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: "Địa chỉ"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: "Quyền"),
                    items: const [
                      DropdownMenuItem(value: "user", child: Text("Khách hàng")),
                      DropdownMenuItem(value: "admin", child: Text("Admin")),
                    ],
                    onChanged: (val) {
                      setStateDialog(() {
                        role = val!;
                      });
                    },
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await DBHelper.instance.updateUser(
                    user['id'],
                    name: nameController.text,
                    phone: phoneController.text,
                    address: addressController.text,
                    role: role,
                  );
                  Navigator.pop(context);
                  _loadUsers();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text("Cập nhật thành công")),
                  );
                },
                child: const Text("Lưu"),
              )
            ],
          );
        });
      },
    );
  }

  void _deleteUser(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa người dùng này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              await DBHelper.instance.deleteUser(id);
              Navigator.pop(context);
              _loadUsers();
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text("Đã xóa người dùng")),
              );
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
        title: const Text("Quản lý Người dùng", style: TextStyle(color: Colors.white)),
        backgroundColor: TColor.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: u['role'] == 'admin' ? Colors.red : TColor.primary,
                      child: Icon(u['role'] == 'admin' ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
                    ),
                    title: Text(u['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${u['email']} | Quyền: ${u['role']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditDialog(u),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(u['id']),
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
