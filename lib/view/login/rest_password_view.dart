import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/view/login/otp_view.dart';
import '../../common/globs.dart';
import '../../common_widget/round_textfield.dart';
import 'package:food_delivery/database/db_helper.dart';
import 'package:food_delivery/common/email_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  TextEditingController txtEmail = TextEditingController();

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
                "Reset Password",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),

               const SizedBox(
                height: 15,
              ),

              Text(
                "Please enter your email to receive a\n reset code to create a new password via email",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 60,
              ),
              RoundTextfield(
                hintText: "Your Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 30,
              ),
             
              RoundButton(title: "Send", onPressed: () {
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
    if (!txtEmail.text.isEmail) {
      mdShowAlert(Globs.appName, MSG.enterEmail, () {});
      return;
    }

    endEditing();

    Globs.showHUD();
    final user = await DBHelper.instance.getUserByEmail(txtEmail.text);
    Globs.hideHUD();

    if (user != null) {
      // Sinh OTP ngẫu nhiên 6 số
      final otpCode = (100000 + Random().nextInt(900000)).toString();

      Globs.showHUD();
      bool isSent = await EmailHelper.sendResetPasswordEmail(txtEmail.text, otpCode);
      Globs.hideHUD();

      if (isSent) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("reset_otp", otpCode); 

        if (mounted) {
          mdShowAlert(Globs.appName, "Mã OTP đã được gửi đến email của bạn", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => OTPView(email: txtEmail.text) ) );
          });
        }
      } else {
        if (mounted) {
          mdShowAlert(Globs.appName, "Có lỗi xảy ra khi gửi email, vui lòng thử lại sau.", () {});
        }
      }
    } else {
      if (mounted) {
        mdShowAlert(Globs.appName, "Email không tồn tại trong hệ thống", () {});
      }
    }
  }
}
