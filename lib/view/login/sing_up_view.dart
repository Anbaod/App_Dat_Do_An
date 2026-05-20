import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/view/login/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widget/round_textfield.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final txtName = TextEditingController();
  final txtMobile = TextEditingController();
  final txtAddress = TextEditingController();
  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConfirmPassword = TextEditingController();

  Future<void> registerAccount() async {
    final name = txtName.text.trim();
    final email = txtEmail.text.trim();
    final mobile = txtMobile.text.trim();
    final address = txtAddress.text.trim();
    final password = txtPassword.text.trim();
    final confirmPassword = txtConfirmPassword.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        mobile.isEmpty ||
        address.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu xác nhận không khớp")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("user_name", name);
    await prefs.setString("user_email", email);
    await prefs.setString("user_mobile", mobile);
    await prefs.setString("user_address", address);
    await prefs.setString("user_password", password);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đăng ký thành công")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  @override
  void dispose() {
    txtName.dispose();
    txtMobile.dispose();
    txtAddress.dispose();
    txtEmail.dispose();
    txtPassword.dispose();
    txtConfirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 64),

              Text(
                "Đăng ký",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),

              Text(
                "Nhập thông tin để tạo tài khoản",
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 25),

              RoundTextfield(hintText: "Tên", controller: txtName),
              const SizedBox(height: 25),

              RoundTextfield(
                hintText: "Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 25),

              RoundTextfield(
                hintText: "Số điện thoại",
                controller: txtMobile,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 25),

              RoundTextfield(hintText: "Địa chỉ", controller: txtAddress),
              const SizedBox(height: 25),

              RoundTextfield(
                hintText: "Mật khẩu",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),

              RoundTextfield(
                hintText: "Xác nhận mật khẩu",
                controller: txtConfirmPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),

              RoundButton(
                title: "Đăng ký",
                onPressed: registerAccount,
              ),

              const SizedBox(height: 30),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  );
                },
                child: Text(
                  "Đã có tài khoản? Đăng nhập",
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}