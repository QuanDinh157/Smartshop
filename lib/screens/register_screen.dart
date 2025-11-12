import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  final AuthService _auth = AuthService();

  void _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await _auth.registerWithEmail(_email.text.trim(), _pass.text);
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tạo tài khoản thành công')));
        Navigator.pop(context); // quay lại login
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi đăng ký: ${e.toString()}')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          children: [
            SizedBox(height: 6),
            Text('Đăng ký tài khoản', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                    validator: (v) => v != null && v.contains('@') ? null : 'Email không hợp lệ',
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    decoration: InputDecoration(labelText: 'Số điện thoại', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v != null && v.length >= 9 ? null : 'Số điện thoại không hợp lệ',
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _pass,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => v != null && v.length >= 6 ? null : 'Mật khẩu tối thiểu 6 ký tự',
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure,
                    decoration: InputDecoration(labelText: 'Nhập lại mật khẩu', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
                    validator: (v) => v == _pass.text ? null : 'Mật khẩu không trùng khớp',
                  ),
                  SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Tạo tài khoản'),
                        style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                  ]),
                  SizedBox(height: 12),
                  Text('Hoặc đăng ký bằng', style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    // placeholder social buttons as in login
                    IconButton(onPressed: () {}, icon: Icon(Icons.g_mobiledata, size: 36)),
                    SizedBox(width: 12),
                    IconButton(onPressed: () {}, icon: Icon(Icons.facebook, size: 36, color: Colors.blue)),
                    SizedBox(width: 12),
                    IconButton(onPressed: () {}, icon: Icon(Icons.apple, size: 36)),
                  ]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
