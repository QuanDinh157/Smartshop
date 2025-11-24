import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'success_screen.dart';
import 'address_screen.dart';
import 'orders_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? itemsToCheckout;
  const CheckoutScreen({super.key, this.itemsToCheckout});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = "Master Card";
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  int _selectedAddressIndex = 0;

  List<Map<String, dynamic>> get _currentItems {
    return widget.itemsToCheckout ?? globalCartItems;
  }

  double get _subTotal {
    double total = 0;
    for (var item in _currentItems) {
      String priceStr = item['product']['price'].toString().replaceAll('.', '').replaceAll(' vnđ', '');
      total += (double.tryParse(priceStr) ?? 0) * item['quantity'];
    }
    return total;
  }

  double get _shippingFee => 18000;
  double get _total => _subTotal + _shippingFee;

  String formatMoney(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} vnđ";
  }

  @override
  Widget build(BuildContext context) {

    final currentAddress = globalAddresses.isNotEmpty
        ? globalAddresses[_selectedAddressIndex]
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text('Xem lại đơn hàng', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ..._currentItems.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(item['product']['imageUrl'], width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['product']['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${item['quantity']} x ${item['product']['price']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        if (item['size'] != null)
                          Text('Size: ${item['size']} | Màu: ${_getColorName(item['color'])}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                  Text(item['product']['price'], style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )).toList(),

            const SizedBox(height: 20),
            // Mã giảm giá
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Mã giảm giá',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300, foregroundColor: Colors.black),
                  child: const Text('Apply'),
                )
              ],
            ),
            const SizedBox(height: 20),

            _buildRowSummary('Tổng tiền', formatMoney(_subTotal)),
            _buildRowSummary('Phí giao hàng', formatMoney(_shippingFee)),
            _buildRowSummary('Thuế', '0'),
            const Divider(height: 30),
            _buildRowSummary('Tổng Hoá Đơn', formatMoney(_total), isBold: true),
            const SizedBox(height: 30),

            _buildSectionHeader('Phương thức thanh toán', () => _showPaymentBottomSheet(context)),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.credit_card, color: Colors.orange, size: 30),
                  const SizedBox(width: 12),
                  Text(_paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Icon(Icons.check_circle, color: Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('Địa chỉ giao hàng', () => _showAddressBottomSheet(context)),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: currentAddress != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentAddress['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(currentAddress['phone']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('${currentAddress['address']}, ${currentAddress['city']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
                  : const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Vui lòng chọn địa chỉ', style: TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () async {
            if (globalAddresses.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng thêm địa chỉ giao hàng!')),
              );
              return;
            }

            final user = _auth.currentUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng đăng nhập trước khi đặt hàng!')),
              );
              return;
            }

            // Tạo dữ liệu đơn hàng (giữ format giống cũ để OrdersScreen dùng lại)
            final newOrder = {
              'id': 'DH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
              'date': DateTime.now().toString().split('.')[0],
              'status': 'Đang giao',
              'total': formatMoney(_total),             // Chuỗi đã format tiền
              'rawTotal': _total,                       // Số double để thống kê nếu cần
              'items': _currentItems.map((item) => {
                'productId': item['product']['id'],
                'name': item['product']['name'],
                'price': item['product']['price'],
                'quantity': item['quantity'],
                'size': item['size'],
                'color': item['color'],
              }).toList(),
              'address': globalAddresses[_selectedAddressIndex],
              'userId': user.uid,
              'createdAt': FieldValue.serverTimestamp(),
            };

            // (Có thể giữ lại dòng này nếu bạn muốn debug local)
            // globalOrders.add(newOrder);

            // Lưu lên Firestore
            await _firestore.collection('orders').add(newOrder);

            setState(() {
              if (widget.itemsToCheckout == null) {
                globalCartItems.clear();
              }
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SuccessScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0857A0),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Thanh toán ${formatMoney(_total)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  String _getColorName(Color color) {
    if (color == Colors.black) return "Đen";
    if (color == Colors.grey) return "Xám";
    return "Xanh";
  }

  Widget _buildRowSummary(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? Colors.black : Colors.grey, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        TextButton(onPressed: onChange, child: const Text('Đổi')),
      ],
    );
  }

  void _showPaymentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Phương Thức Thanh Toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              _paymentOption('Thanh Toán Khi Nhận Hàng', Icons.local_shipping),
              _paymentOption('VISA', Icons.payment),
              _paymentOption('Master Card', Icons.credit_card),
              _paymentOption('Paypal', Icons.account_balance_wallet),
            ],
          ),
        );
      },
    );
  }

  Widget _paymentOption(String name, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(name),
      trailing: _paymentMethod == name ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        setState(() {
          _paymentMethod = name;
        });
        Navigator.pop(context);
      },
    );
  }


  void _showAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Text('Chọn Địa Chỉ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              const SizedBox(height: 20),
              Expanded(
                child: globalAddresses.isEmpty
                    ? const Center(child: Text("Chưa có địa chỉ nào."))
                    : ListView.builder(
                  itemCount: globalAddresses.length,
                  itemBuilder: (ctx, index) {
                    final item = globalAddresses[index];
                    final isSelected = index == _selectedAddressIndex;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: isSelected ? const Color(0xFF0857A0) : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                        color: isSelected ? const Color(0xFF0857A0).withOpacity(0.05) : Colors.white,
                      ),
                      child: ListTile(
                        title: Text(item['address']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${item['city']} \n${item['name']} | ${item['phone']}'),
                        isThreeLine: true,
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF0857A0)) : null,
                        onTap: () {
                          setState(() {
                            _selectedAddressIndex = index;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen())).then((_) {
                    setState(() {});
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.add), Text('Quản lý địa chỉ')],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}