import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedColorIndex = 0;
  String _selectedSize = 'M';

  final List<Color> _colors = [
    Colors.grey,
    Colors.black,
    const Color(0xFF0A75AD),
  ];

  final List<String> _sizes = ['S', 'M', 'L', 'XL'];

  // Hàm thêm vào giỏ hàng (Chỉ dùng cho nút Thêm vào giỏ)
  void _addToCart() {
    setState(() {
      bool exists = false;
      for (var item in globalCartItems) {
        if (item['product']['id'] == widget.product['id']) {
          item['quantity'] += _quantity;
          exists = true;
          break;
        }
      }
      if (!exists) {
        globalCartItems.add({
          'product': widget.product,
          'quantity': _quantity,
          'size': _selectedSize,
          'color': _colors[_selectedColorIndex],
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm vào giỏ hàng!'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final price = product['price'] ?? '0 vnđ';
    final originalPrice = '879.000';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewImageScreen(imageUrl: product['imageUrl']),
                      ),
                    ),
                    child: Center(
                      child: Hero(
                        tag: product['id'],
                        child: _buildProductImage(product['imageUrl']),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        originalPrice,
                        style: const TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEEA96),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product['discount'] ?? '-0%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['name'],
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.share, size: 24),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      text: 'Tình trạng: ',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Còn hàng',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ...List.generate(
                        _colors.length,
                            (index) => GestureDetector(
                          onTap: () => setState(() => _selectedColorIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: _selectedColorIndex == index
                                  ? Border.all(color: Colors.grey, width: 1)
                                  : null,
                            ),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: _colors[index],
                              child: _selectedColorIndex == index
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedSize,
                          underline: const SizedBox(),
                          items: _sizes
                              .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                              .toList(),
                          onChanged: (newValue) => setState(() => _selectedSize = newValue!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Số lượng', style: TextStyle(color: Colors.grey)),
                      ),
                      const Spacer(),
                      _buildQuantityBtn(Icons.remove, () {
                        if (_quantity > 1) setState(() => _quantity--);
                      }),
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      _buildQuantityBtn(Icons.add, () => setState(() => _quantity++)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Mô tả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    product['description'] ?? 'Chưa có mô tả chi tiết.',
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {},
                    child: const Text('xem thêm', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: _addToCart,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Thêm vào giỏ hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),


                ElevatedButton(
                  onPressed: () {
                    final itemToBuy = {
                      'product': widget.product,
                      'quantity': _quantity,
                      'size': _selectedSize,
                      'color': _colors[_selectedColorIndex],
                    };

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(itemsToCheckout: [itemToBuy]),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF0857A0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thanh Toán', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Color(0xFF0857A0), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, height: 300, fit: BoxFit.contain);
    }
    return Image.asset(imageUrl, height: 300, fit: BoxFit.contain);
  }
}

class ViewImageScreen extends StatelessWidget {
  final String imageUrl;
  const ViewImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('View image', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Spacer(),
          Hero(
            tag: 'product_image_full',
            child: imageUrl.startsWith('http')
                ? Image.network(imageUrl, fit: BoxFit.contain)
                : Image.asset(imageUrl, fit: BoxFit.contain),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.black,
              ),
              child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}