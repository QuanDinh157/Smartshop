import 'package:flutter/material.dart';
import 'checkout_screen.dart';

List<Map<String, dynamic>> globalCartItems = [];

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  // Hàm tính tổng tiền
  double get _totalPrice {
    double total = 0;
    for (var item in globalCartItems) {
      String priceStr = item['product']['price'].toString().replaceAll('.', '').replaceAll(' vnđ', '');
      double price = double.tryParse(priceStr) ?? 0;
      total += price * item['quantity'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,

        automaticallyImplyLeading: false,
        leading: canPop
            ? const BackButton(color: Colors.black)
            : null,
      ),
      body: globalCartItems.isEmpty ? _buildEmptyCart() : _buildCartList(),

      bottomNavigationBar: globalCartItems.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0857A0),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Tiếp tục', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFEEA96),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_outlined, size: 50, color: Colors.black),
          ),
          const SizedBox(height: 20),
          const Text('Giỏ hàng của bạn trống!', style: TextStyle(fontSize: 18, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: globalCartItems.length,
      itemBuilder: (context, index) {
        final item = globalCartItems[index];
        final product = item['product'];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(product['imageUrl'], width: 70, height: 70, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: item['color'], shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('Size: ${item['size']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(product['price'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Row(
                          children: [
                            _qtyBtn(Icons.remove, () {
                              setState(() {
                                if (item['quantity'] > 1) {
                                  item['quantity']--;
                                } else {
                                  globalCartItems.removeAt(index);
                                }
                              });
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            _qtyBtn(Icons.add, () {
                              setState(() => item['quantity']++);
                            }),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: const Color(0xFF0857A0), borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }
}