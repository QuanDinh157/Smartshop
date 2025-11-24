import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final String orderId;

  const OrderDetailScreen({super.key, required this.order, required this.orderId});

  @override
  Widget build(BuildContext context) {
    List items = order['items'] ?? [];
    Color statusColor = order['status'] == 'Đã giao' ? Colors.green : Colors.orange;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thông tin chung
            _buildSectionTitle("Thông tin đơn hàng"),
            _buildInfoRow("Mã đơn:", orderId),
            _buildInfoRow("Ngày đặt:", order['date'] ?? 'N/A'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Trạng thái:", style: TextStyle(color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(order['status'] ?? 'Đang xử lý', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const Divider(height: 30),

            // 2. Địa chỉ giao hàng
            _buildSectionTitle("Địa chỉ nhận hàng"),
            Text(order['address'] ?? "Không có địa chỉ", style: const TextStyle(fontSize: 15)),
            const Divider(height: 30),

            // 3. Danh sách sản phẩm
            _buildSectionTitle("Danh sách sản phẩm (${items.length})"),
            ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (item['image'] != null && item['image'].startsWith('http'))
                        ? Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover)
                        : Image.asset(item['image'] ?? 'assets/images/placeholder.png', width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width: 50, height: 50, color: Colors.grey)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] ?? 'Sản phẩm', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("${item['quantity']} x ${item['price']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const Divider(height: 30),

            // 4. Tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Thành tiền:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(order['total'] ?? '0đ', style: const TextStyle(color: Color(0xFF0857A0), fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}