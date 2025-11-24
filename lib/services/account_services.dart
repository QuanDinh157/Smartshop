import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AccountServices {
  // Hàm gửi feedback lên Realtime Database
  Future<void> sendFeedback({
    required BuildContext context,
    required String content,
  }) async {
    try {
      // 1. Kết nối đến nhánh "feedbacks" trên Database
      DatabaseReference ref = FirebaseDatabase.instance.ref("feedbacks");

      // 2. Đẩy dữ liệu lên
      await ref.push().set({
        "content": content,
        "timestamp": DateTime.now().toString(),
        "user_type": "Guest", // Hoặc lấy tên user thật
      });

      // 3. Thông báo thành công và thoát
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi góp ý thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }
}