import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartshop/screens/home_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/sent_mail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SmartShopApp());
}

class SmartShopApp extends StatelessWidget {
  const SmartShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartShop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (_) => const LoadingScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/sent': (_) => const SentMailScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
// ccccc