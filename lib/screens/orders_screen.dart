import 'package:flutter/material.dart';

List<Map<String, dynamic>> globalOrders = [];

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),

      body: globalOrders.isEmpty
          ? const Center(child: Text("Bạn chưa có đơn hàng nào"))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: globalOrders.length,
        itemBuilder: (context, index) {

          final order = globalOrders[globalOrders.length - 1 - index];

          return _buildOrderItem(order);
        },
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    Color statusColor = order['status'] == 'Đang giao' ? Colors.orange : Colors.green;

    return Container(
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
              Text(order['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(order['status'], style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(order['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Divider(height: 24),


          ... (order['items'] as List).take(2).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text("- ${item['quantity']} x ${item['product']['name']}", style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          )),

          if ((order['items'] as List).length > 2)
            const Text("...", style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(order['items'] as List).length} Sản phẩm', style: const TextStyle(color: Colors.grey)),
              Text('Tổng: ${order['total']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0857A0))),
            ],
          )
        ],
      ),
    );
  }
} //sdvkjsdbv