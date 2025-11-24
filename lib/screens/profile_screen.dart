import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase
import 'package:flutter/material.dart';
import 'package:smartshop/screens/feedback_screen.dart';

import 'edit_profile_screen.dart';
import 'address_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'orders_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {

    String displayName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Khách hàng';
    String email = user?.email ?? 'Chưa đăng nhập';
    String phone = user?.phoneNumber ?? 'SĐT: (Chưa cập nhật)';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [

          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFF0857A0),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),


          ListView(
            padding: const EdgeInsets.fromLTRB(20, 150, 20, 20),
            children: [

              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phone,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                            },
                            child: const Text('Edit', style: TextStyle(color: Color(0xFF0857A0), fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),


                  Positioned(
                    top: 0,
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                        child: (user?.photoURL == null) ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),


              _buildMenuItem(context, 'Địa chỉ của tôi', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen()));
              }),
              _buildMenuItem(context, 'Wishlist', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => WishlistScreen(likedProductIds: const {}, onFavoriteToggle: (_) {})));
              }),
              _buildMenuItem(context, 'Giỏ hàng', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              }),


              _buildMenuItem(context, 'Đơn hàng', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
              }),


              _buildMenuItem(context, 'Đổi mật khẩu', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
              }),

              _buildMenuItem(context, 'Gửi Góp Ý & Phản Hồi', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen()));
              }),

              const SizedBox(height: 20),


              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0857A0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),


          const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 20, top: 10),
              child: Text(
                'UserInfo',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }
}