import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/social_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _remember = false;
  bool _loading = false;
  final AuthService _auth = AuthService();

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await _auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text.trim());
      if (user != null) {
        // success: chuyển sang Home (ở đây tạm quay lại login / hoặc bạn thay route)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng nhập thành công')));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Lỗi đăng nhập')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _googleSignIn() async {
    setState(() => _loading = true);
    try {
      final user = await _auth.signInWithGoogle();
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng nhập Google thành công')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi Google Sign-In')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            SizedBox(height: 6),
            // Logo
            Column(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.shopping_cart, size: 56, color: primaryBlue),
                ),
                SizedBox(height: 12),
                Text('SmartShop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Đăng nhập để tiếp tục', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@') ? null : 'Email không hợp lệ',
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v != null && v.length >= 6 ? null : 'Mật khẩu tối thiểu 6 ký tự',
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false)),
                    Text('Nhớ tài khoản'),
                    Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot'),
                      child: Text('Quên mật khẩu?', style: TextStyle(color: primaryBlue)),
                    )
                  ],
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _signIn,
                    child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Đăng nhập'),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text('Tạo tài khoản'),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                SizedBox(height: 16),
                Text('Hoặc đăng nhập bằng', style: TextStyle(color: Colors.grey[600])),
                SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SocialButton(
                    onPressed: _googleSignIn,
                    child: Image.asset('assets/google.png', width: 28, height: 28),
                  ),
                  SizedBox(width: 12),
                  SocialButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chưa cấu hình Facebook')));
                    },
                    child: Icon(Icons.facebook, size: 28, color: Colors.blue),
                  ),
                  SizedBox(width: 12),
                  SocialButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chưa cấu hình Apple')));
                    },
                    child: Icon(Icons.apple, size: 28),
                  ),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
