import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'success_screen.dart';
import 'address_screen.dart';
import 'orders_screen.dart'; // Import để dùng biến toàn cục nếu cần
import 'package:cloud_firestore/cloud_firestore.dart'; // QUAN TRỌNG: Để lưu đơn
import 'package:firebase_auth/firebase_auth.dart';     // QUAN TRỌNG: Để lấy User ID

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? itemsToCheckout;
  const CheckoutScreen({super.key, this.itemsToCheckout});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = "Master Card";
  int _selectedAddressIndex = 0;

  // Khởi tạo Firebase
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false; // Biến để hiện vòng xoay khi đang lưu

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

  // --- HÀM XỬ LÝ THANH TOÁN & LƯU FIREBASE ---
  void _handlePayment() async {
    // 1. Kiểm tra địa chỉ
    if (globalAddresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm địa chỉ giao hàng!')));
      return;
    }

    // 2. Kiểm tra đăng nhập
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập để thanh toán!')));
      return;
    }

    setState(() => _isLoading = true); // Bắt đầu xoay

    try {
      final currentAddress = globalAddresses[_selectedAddressIndex];

      // 3. Tạo dữ liệu đơn hàng chuẩn
      final newOrder = {
        'userId': user.uid,
        'email': user.email,
        'status': 'Đang xử lý',
        'total': formatMoney(_total), // Tổng tiền dạng chuỗi
        'rawTotal': _total,           // Tổng tiền dạng số
        'date': DateTime.now().toString().split('.')[0],
        'createdAt': FieldValue.serverTimestamp(), // Giờ Server
        'paymentMethod': _paymentMethod,
        'address': '${currentAddress['address']}, ${currentAddress['city']}',
        'phone': currentAddress['phone'],
        'receiverName': currentAddress['name'],

        // Danh sách sản phẩm
        'items': _currentItems.map((item) => {
          'productId': item['product']['id'],
          'name': item['product']['name'],       // Lưu tên trực tiếp để dễ lấy
          'price': item['product']['price'],
          'quantity': item['quantity'],
          'image': item['product']['imageUrl'],
          'size': item['size'] ?? 'M',
          'color': item['color']?.value ?? 0,
        }).toList(),
      };

      // 4. Gửi lên Firestore
      await _firestore.collection('orders').add(newOrder);

      // 5. Xử lý sau khi lưu thành công
      // Nếu mua từ giỏ hàng thì xóa giỏ hàng đi
      if (widget.itemsToCheckout == null) {
        setState(() {
          globalCartItems.clear();
        });
      }

      if (mounted) {
        // Chuyển sang màn hình thành công
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SuccessScreen()),
        );
      }
    } catch (e) {
      print("Lỗi thanh toán: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false); // Tắt xoay
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiện vòng xoay khi đang lưu
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Danh sách sản phẩm
            ..._currentItems.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (item['product']['imageUrl'].toString().startsWith('http'))
                        ? Image.network(item['product']['imageUrl'], width: 60, height: 60, fit: BoxFit.cover)
                        : Image.asset(item['product']['imageUrl'], width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['product']['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${item['quantity']} x ${item['product']['price']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        if (item['size'] != null)
                          Text('Size: ${item['size']}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                  Text(item['product']['price'], style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )).toList(),

            const SizedBox(height: 20),
            const Divider(),

            // Tổng tiền
            _buildRowSummary('Tổng tiền', formatMoney(_subTotal)),
            _buildRowSummary('Phí giao hàng', formatMoney(_shippingFee)),
            const Divider(height: 30),
            _buildRowSummary('Tổng Hoá Đơn', formatMoney(_total), isBold: true),
            const SizedBox(height: 30),

            // Phương thức thanh toán
            _buildSectionHeader('Phương thức thanh toán', () => _showPaymentBottomSheet(context)),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.orange, size: 30),
                  const SizedBox(width: 12),
                  Text(_paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Icon(Icons.check_circle, color: Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Địa chỉ
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
          onPressed: _isLoading ? null : _handlePayment, // Gọi hàm thanh toán
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0857A0),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
              _isLoading ? 'Đang xử lý...' : 'Thanh toán ${formatMoney(_total)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    );
  }

  // --- CÁC HÀM PHỤ TRỢ ---
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