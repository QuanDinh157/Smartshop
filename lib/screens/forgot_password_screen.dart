import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _loading = false;
  final AuthService _auth = AuthService();

  void _sendReset() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.sendPasswordReset(_email.text.trim());
      // navigate to sent mail screen
      Navigator.pushReplacementNamed(context, '/sent');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: Colors.black)),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            SizedBox(height: 6),
            Text('Quên mật khẩu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Nhập email của bạn để nhận đường dẫn đặt lại mật khẩu', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 18),
            Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(labelText: 'Nhập Email của bạn', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                    validator: (v) => v != null && v.contains('@') ? null : 'Email không hợp lệ',
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _sendReset,
                      child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Tiếp tục'),
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
