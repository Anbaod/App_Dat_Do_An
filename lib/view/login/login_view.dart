import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/view/login/rest_password_view.dart';
import 'package:food_delivery/view/login/sing_up_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widget/round_icon_button.dart';
import '../../common_widget/round_textfield.dart';
import '../main_tabview/main_tabview.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();

  Future<void> login() async {
    String email = txtEmail.text.trim();
    String password = txtPassword.text.trim();

    final prefs = await SharedPreferences.getInstance();

    String savedName = prefs.getString("user_name") ?? "";
    String savedEmail = prefs.getString("user_email") ?? "";
    String savedPassword = prefs.getString("user_password") ?? "";

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ email và mật khẩu")),
      );
      return;
    }

    if (savedEmail.isEmpty || savedPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chưa có tài khoản. Vui lòng đăng ký trước")),
      );
      return;
    }

    if (email == savedEmail && password == savedPassword) {
      await prefs.setBool("is_login", true);

      await prefs.setString("current_user_name", savedName);
      await prefs.setString("current_user_email", savedEmail);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng nhập thành công")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainTabView(),
        ),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sai email hoặc mật khẩu")),
      );
    }
  }

  @override
  void dispose() {
    txtEmail.dispose();
    txtPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),

              Text(
                "Đăng nhập",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),

              Text(
                "Nhập thông tin để đăng nhập",
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 25),

              RoundTextfield(
                hintText: "Email của bạn",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 25),

              RoundTextfield(
                hintText: "Mật khẩu",
                controller: txtPassword,
                obscureText: true,
              ),

              const SizedBox(height: 25),

              RoundButton(
                title: "Đăng nhập",
                onPressed: login,
              ),

              const SizedBox(height: 4),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetPasswordView(),
                    ),
                  );
                },
                child: Text(
                  "Quên mật khẩu?",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Hoặc đăng nhập bằng",
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              RoundIconButton(
                icon: "assets/img/facebook_logo.png",
                title: "Đăng nhập bằng Facebook",
                color: const Color(0xff367FC0),
                onPressed: () {},
              ),

              const SizedBox(height: 25),

              RoundIconButton(
                icon: "assets/img/google_logo.png",
                title: "Đăng nhập bằng Google",
                color: const Color(0xffDD4B39),
                onPressed: () {},
              ),

              const SizedBox(height: 80),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpView(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Chưa có tài khoản? ",
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Đăng ký",
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}