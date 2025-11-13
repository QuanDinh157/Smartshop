import 'package:flutter/material.dart';

class SentMailScreen extends StatelessWidget {
  const SentMailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/google.png', width: 90),
                const SizedBox(height: 32),
                const Icon(Icons.mail_outline, size: 80, color: Colors.orange),
                const SizedBox(height: 24),
                const Text(
                  'Email đặt lại mật khẩu đã được gửi đến bạn',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A75AD),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Quay lại trang đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
