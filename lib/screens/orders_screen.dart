import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_detail_screen.dart'; // Đảm bảo bạn đã tạo file này như hướng dẫn trước

// Biến toàn cục (Giữ lại để tránh lỗi file khác)
List<Map<String, dynamic>> globalOrders = [];

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    // Kiểm tra đăng nhập
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Vui lòng đăng nhập để xem đơn hàng")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // --- QUAN TRỌNG: Đã bỏ orderBy để đảm bảo hiện dữ liệu ---
        stream: _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        // ---------------------------------------------------------

        builder: (context, snapshot) {
          // 1. Xử lý lỗi
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Lỗi tải dữ liệu: ${snapshot.error}", textAlign: TextAlign.center),
              ),
            );
          }

          // 2. Đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Dữ liệu rỗng
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  const Text("Bạn chưa có đơn hàng nào", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              try {
                final data = orders[index].data() as Map<String, dynamic>;
                String orderId = orders[index].id;
                return _buildOrderItem(data, orderId);
              } catch (e) {
                return const SizedBox(); // Bỏ qua item lỗi
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order, String orderId) {
    // Màu trạng thái
    Color statusColor = Colors.orange;
    String status = order['status'] ?? 'Đang xử lý';
    if (status == 'Đã giao' || status == 'Hoàn thành') statusColor = Colors.green;
    if (status == 'Hủy') statusColor = Colors.red;

    // Lấy danh sách sản phẩm an toàn
    List items = [];
    if (order['items'] != null && order['items'] is List) {
      items = order['items'];
    }

    // Format ngày
    String dateStr = order['date'] ?? 'Vừa đặt';
    if (dateStr.length > 16) dateStr = dateStr.substring(0, 16);

    return GestureDetector(
      onTap: () {
        // Chuyển sang chi tiết đơn hàng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(order: order, orderId: orderId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mã đơn hàng
                Text(
                    "Đơn #${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length).toUpperCase()}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(height: 15),

            // Danh sách món (Hiển thị tối đa 2)
            if (items.isNotEmpty)
              ...items.take(2).map((item) {
                // Lấy tên sản phẩm (thử nhiều key phòng hờ)
                String name = item['name'] ?? item['productName'] ?? 'Sản phẩm';
                var qty = item['quantity'] ?? 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text("- $qty x $name", style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                );
              }),

            if (items.isEmpty)
              const Text("Đang cập nhật danh sách món...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),

            if (items.length > 2)
              Text("+ ${items.length - 2} sản phẩm khác...", style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${items.length} món', style: const TextStyle(color: Colors.grey)),
                Text(
                    order['total'] ?? '0đ',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0857A0), fontSize: 16)
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}