import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailHelper {
  static const String smtpUsername = 'ntn1552k4@gmail.com';
  static const String smtpPassword = 'mtckgxkxmobxvwih';

  static Future<bool> sendResetPasswordEmail(String toEmail, String otpCode) async {
    final smtpServer = gmail(smtpUsername, smtpPassword);

    final message = Message()
      ..from = Address(smtpUsername, 'FastFood')
      ..recipients.add(toEmail)
      ..subject = 'Mã xác nhận đặt lại mật khẩu - FastFood'
      ..html = '''
      <!DOCTYPE html>
      <html>
      <head><meta charset='UTF-8'></head>
      <body>
        <h2>Mã xác nhận đặt lại mật khẩu</h2>
        <p>Mã của bạn: <b>$otpCode</b></p>
      </body>
      </html>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    } catch (e) {
      print('Message not sent (General Error): $e');
      return false;
    }
  }

  static Future<bool> sendWelcomeEmail(String toEmail, String userName) async {
    final smtpServer = gmail(smtpUsername, smtpPassword);

    final message = Message()
      ..from = Address(smtpUsername, 'FastFood')
      ..recipients.add(toEmail)
      ..subject = '🎉 Chào mừng bạn đến với FastFood!'
      ..html = '''
      <!DOCTYPE html>
      <html>
      <head><meta charset='UTF-8'></head>
      <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f4f4f9;'>
        <div style='background: linear-gradient(135deg, #FF9B26 0%, #FF5A00 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;'>
          <h1 style='color: white; margin: 0; font-size: 28px;'>FastFood</h1>
        </div>
        <div style='background: white; padding: 30px; border-radius: 0 0 10px 10px; border: 1px solid #e0e0e0; border-top: none;'>
          <h2 style='color: #FF5A00; margin-top: 0; text-align: center;'>Chào mừng $userName! 🎉</h2>
          <p style='font-size: 16px; text-align: center;'>Cảm ơn bạn đã đăng ký tài khoản thành công tại <strong>FastFood</strong>.</p>
          
          <div style='background: #fff5f0; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #FF5A00;'>
            <p style='margin: 10px 0; font-size: 15px;'>Bây giờ bạn đã có thể bắt đầu trải nghiệm:</p>
            <ul style='margin: 0; padding-left: 20px; color: #555;'>
              <li style='margin-bottom: 8px;'>Khám phá hàng ngàn món ăn ngon 🍔</li>
              <li style='margin-bottom: 8px;'>Theo dõi đơn hàng dễ dàng 🛵</li>
              <li>Nhận nhiều ưu đãi độc quyền 🎁</li>
            </ul>
          </div>
          
          <div style='text-align: center; margin-top: 30px;'>
            <div style='background: #FF5A00; color: white; padding: 12px 25px; text-decoration: none; border-radius: 25px; font-weight: bold; font-size: 16px; display: inline-block;'>Hãy bắt đầu đặt món ngay!</div>
          </div>
          
          <div style='margin-top: 30px; padding-top: 20px; border-top: 1px solid #e0e0e0; text-align: center;'>
            <p style='margin: 5px 0; color: #666; font-size: 14px;'>Nếu bạn có bất kỳ câu hỏi nào, vui lòng liên hệ với chúng tôi để được hỗ trợ.</p>
            <p style='margin: 5px 0; color: #666; font-size: 14px;'>Trân trọng,<br><strong>Đội ngũ FastFood</strong></p>
          </div>
        </div>
      </body>
      </html>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Welcome Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Welcome Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    } catch (e) {
      print('Welcome Message not sent (General Error): $e');
      return false;
    }
  }

  static Future<bool> sendReviewThankYouEmail(String toEmail, String orderId) async {
    final smtpServer = gmail(smtpUsername, smtpPassword);

    final message = Message()
      ..from = Address(smtpUsername, 'FastFood')
      ..recipients.add(toEmail)
      ..subject = 'Cảm ơn bạn đã đánh giá đơn hàng #$orderId!'
      ..html = '''
      <!DOCTYPE html>
      <html>
      <head><meta charset='UTF-8'></head>
      <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f4f4f9;'>
        <div style='background: linear-gradient(135deg, #FF9B26 0%, #FF5A00 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;'>
          <h1 style='color: white; margin: 0; font-size: 28px;'>FastFood</h1>
        </div>
        <div style='background: white; padding: 30px; border-radius: 0 0 10px 10px; border: 1px solid #e0e0e0; border-top: none;'>
          <h2 style='color: #FF5A00; margin-top: 0; text-align: center;'>Cảm ơn bạn rất nhiều! ⭐</h2>
          <p style='font-size: 16px; text-align: center;'>Chúng tôi đã nhận được đánh giá của bạn cho đơn hàng <strong>#$orderId</strong>.</p>
          
          <div style='background: #fff5f0; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #FF5A00; text-align: center;'>
            <p style='margin: 10px 0; font-size: 15px;'>Mỗi phản hồi của bạn đều giúp FastFood cải thiện dịch vụ tốt hơn từng ngày!</p>
          </div>
          
          <div style='margin-top: 30px; padding-top: 20px; border-top: 1px solid #e0e0e0; text-align: center;'>
            <p style='margin: 5px 0; color: #666; font-size: 14px;'>Hẹn gặp lại bạn trong những bữa ăn tiếp theo nhé.</p>
            <p style='margin: 5px 0; color: #666; font-size: 14px;'>Trân trọng,<br><strong>Đội ngũ FastFood</strong></p>
          </div>
        </div>
      </body>
      </html>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Review Thank You Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Review Thank You Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }
}
