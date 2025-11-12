import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/sent_mail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // nếu bạn đã config Firebase bên ngoài, để nguyên
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color primaryBlue = const Color(0xFF0A66C2); // chỉnh nếu cần

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartShop Auth',
      theme: ThemeData(
        primaryColor: primaryBlue,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: primaryBlue),
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (_) => LoadingScreen(),
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/forgot': (_) => ForgotPasswordScreen(),
        '/sent': (_) => SentMailScreen(),
      },
    );
  }
}
