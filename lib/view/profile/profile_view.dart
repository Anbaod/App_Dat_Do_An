import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_delivery/database/db_helper.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../login/login_view.dart';
import '../more/my_order_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker picker = ImagePicker();
  XFile? image;

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();

  String userName = "";

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("current_user_email") ?? prefs.getString("user_email");

    if (email != null && email.isNotEmpty) {
      try {
        final user = await DBHelper.instance.getUserByEmail(email);
        if (user != null) {
          setState(() {
            userName = user["name"] ?? "Người dùng";
            txtName.text = user["name"] ?? "";
            txtEmail.text = user["email"] ?? "";
            txtMobile.text = user["phone"] ?? "";
            txtAddress.text = user["address"] ?? "";
            txtPassword.text = user["password"] ?? "";
            txtConfirmPassword.text = user["password"] ?? "";
          });
          return;
        }
      } catch (e) {
        debugPrint("Lỗi loadUserInfo từ DB: $e");
      }
    }

    setState(() {
      userName = prefs.getString("current_user_name") ??
          prefs.getString("user_name") ??
          "Người dùng";

      txtName.text = prefs.getString("current_user_name") ??
          prefs.getString("user_name") ??
          "";

      txtEmail.text = prefs.getString("current_user_email") ??
          prefs.getString("user_email") ??
          "";

      txtMobile.text = prefs.getString("user_mobile") ?? "";
      txtAddress.text = prefs.getString("user_address") ?? "";
      txtPassword.text = prefs.getString("user_password") ?? "";
      txtConfirmPassword.text = prefs.getString("user_password") ?? "";
    });
  }

  Future<void> saveUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("current_user_id");
    final originalEmail = prefs.getString("current_user_email") ?? prefs.getString("user_email") ?? "";

    if (txtPassword.text.trim() != txtConfirmPassword.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mật khẩu xác nhận không khớp"),
        ),
      );
      return;
    }

    final newName = txtName.text.trim();
    final newEmail = txtEmail.text.trim();
    final newPhone = txtMobile.text.trim();
    final newAddress = txtAddress.text.trim();
    final newPassword = txtPassword.text.trim();

    if (newName.isEmpty || newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tên và Email không được để trống"),
        ),
      );
      return;
    }

    try {
      if (userId != null) {
        await DBHelper.instance.updateUser(
          id: userId,
          name: newName,
          email: newEmail,
          phone: newPhone,
          address: newAddress,
        );
        if (newPassword.isNotEmpty) {
          await DBHelper.instance.updateUserPassword(newEmail, newPassword);
        }
      } else if (originalEmail.isNotEmpty) {
        final dbUser = await DBHelper.instance.getUserByEmail(originalEmail);
        if (dbUser != null) {
          final dbId = dbUser["id"] as int;
          await DBHelper.instance.updateUser(
            id: dbId,
            name: newName,
            email: newEmail,
            phone: newPhone,
            address: newAddress,
          );
          if (newPassword.isNotEmpty) {
            await DBHelper.instance.updateUserPassword(newEmail, newPassword);
          }
          await prefs.setInt("current_user_id", dbId);
        }
      }

      await prefs.setString("user_name", newName);
      await prefs.setString("user_email", newEmail);
      await prefs.setString("user_mobile", newPhone);
      await prefs.setString("user_address", newAddress);
      await prefs.setString("user_password", newPassword);
      await prefs.setString("current_user_name", newName);
      await prefs.setString("current_user_email", newEmail);

      setState(() {
        userName = newName;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cập nhật thông tin thành công"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi lưu thông tin: $e"),
          ),
        );
      }
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_login", false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginView(),
      ),
          (route) => false,
    );
  }

  @override
  void dispose() {
    txtName.dispose();
    txtEmail.dispose();
    txtMobile.dispose();
    txtAddress.dispose();
    txtPassword.dispose();
    txtConfirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 46),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hồ sơ cá nhân",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyOrderView(),
                          ),
                        );
                      },
                      icon: Image.asset(
                        "assets/img/shopping_cart.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: TColor.placeholder,
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center,
                child: image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.file(
                    File(image!.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.person,
                  size: 65,
                  color: TColor.secondaryText,
                ),
              ),

              TextButton.icon(
                onPressed: () async {
                  image = await picker.pickImage(source: ImageSource.gallery);
                  setState(() {});
                },
                icon: Icon(
                  Icons.edit,
                  color: TColor.primary,
                  size: 12,
                ),
                label: Text(
                  "Chỉnh sửa ảnh",
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 12,
                  ),
                ),
              ),

              Text(
                "Xin chào $userName!",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              TextButton(
                onPressed: signOut,
                child: Text(
                  "Đăng xuất",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 20,
                ),
                child: RoundTitleTextfield(
                  title: "Tên",
                  hintText: "Nhập tên",
                  controller: txtName,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 20,
                ),
                child: RoundTitleTextfield(
                  title: "Email",
                  hintText: "Nhập email",
                  keyboardType: TextInputType.emailAddress,
                  controller: txtEmail,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 20,
                ),
                child: RoundTitleTextfield(
                  title: "Số điện thoại",
                  hintText: "Nhập số điện thoại",
                  controller: txtMobile,
                  keyboardType: TextInputType.phone,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 20,
                ),
                child: RoundTitleTextfield(
                  title: "Địa chỉ",
                  hintText: "Nhập địa chỉ",
                  controller: txtAddress,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 20,
                ),
                child: RoundTitleTextfield(
                  title: "Mật khẩu",
                  hintText: "* * * * * *",
                  obscureText: true,
                  controller: txtPassword,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 20,
                ),
                child: RoundTitleTextfield(
                  title: "Xác nhận mật khẩu",
                  hintText: "* * * * * *",
                  obscureText: true,
                  controller: txtConfirmPassword,
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundButton(
                  title: "Lưu thông tin",
                  onPressed: saveUserInfo,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}