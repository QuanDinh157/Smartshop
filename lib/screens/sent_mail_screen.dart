import 'package:flutter/material.dart';

class SentMailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: Colors.black)),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.send_rounded, size: 96, color: primaryBlue),
            SizedBox(height: 18),
            Text('Email đặt lại mật khẩu đã được gửi đến bạn', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: Text('Quay lại trang đăng nhập'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18)),
            )
          ]),
        ),
      ),
    );
  }
}
