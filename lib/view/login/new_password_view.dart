import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/view/login/login_view.dart';
import '../../common/globs.dart';
import '../../common_widget/round_textfield.dart';
import 'package:food_delivery/database/db_helper.dart';

class NewPasswordView extends StatefulWidget {
  final Map nObj;
  const NewPasswordView({super.key, required this.nObj});

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 64,
              ),
              Text(
                "New Password",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Please enter your new password",
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 60,
              ),
              RoundTextfield(
                hintText: "New Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(
                height: 25,
              ),
               RoundTextfield(
                hintText: "Confirm Password",
                controller: txtConfirmPassword,
                obscureText: true,
              ),
              const SizedBox(
                height: 30,
              ),
              RoundButton(title: "Next", onPressed: () {
                btnSubmit();
              }),
            ],
          ),
        ),
      ),
    );
  }

   //TODO: Action
  void btnSubmit() async {

    if(txtPassword.text.length <6) {
      mdShowAlert(Globs.appName, MSG.enterPassword, () { });
      return;
    }

    if (txtPassword.text != txtConfirmPassword.text) {
      mdShowAlert(Globs.appName, MSG.enterPasswordNotMatch, () {});
      return;
    }

    endEditing();

    String email = widget.nObj["email"] ?? "";
    if (email.isNotEmpty) {
      Globs.showHUD();
      await DBHelper.instance.updateUserPassword(email, txtPassword.text);
      await DBHelper.instance.insertNotification(
        title: "Đổi mật khẩu thành công", 
        message: "Mật khẩu của tài khoản $email đã được thay đổi thành công."
      );
      Globs.hideHUD();

      if (mounted) {
        mdShowAlert(Globs.appName, "Đổi mật khẩu thành công!", () {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginView() ), (route) => false);
        });
      }
    } else {
      if (mounted) {
        mdShowAlert(Globs.appName, "Lỗi: Không tìm thấy email", () {});
      }
    }
  }
}
