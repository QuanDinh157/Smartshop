import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import 'home_screen.dart' hide ProductCard;

class WishlistScreen extends StatelessWidget {

  final Set<String> likedProductIds;
  final Function(String) onFavoriteToggle;

  const WishlistScreen({
    super.key,
    required this.likedProductIds,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> favoriteProducts = allProducts
        .where((product) => likedProductIds.contains(product['id']))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Yêu thích',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
      ),
      body: favoriteProducts.isEmpty
          ? _buildEmptyWishlist()
          : _buildWishlistGrid(favoriteProducts),
    );
  }

  /// WIDGET: Hiển thị khi danh sách yêu thích rỗng
  Widget _buildEmptyWishlist() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0857A0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.list_alt_rounded,
                color: Color(0xFF0857A0),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Thêm sản phẩm yêu thích',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sản phẩm yêu thích của bạn sẽ được hiển thị tại đây. Vui lòng thêm sản phẩm.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Nói HomeScreen chuyển về tab 0
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0857A0),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Thêm sản phẩm'),
            ),
          ],
        ),
      ),
    );
  }

  /// WIDGET: Hiển thị lưới sản phẩm
  Widget _buildWishlistGrid(List<Map<String, dynamic>> favoriteProducts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${favoriteProducts.length} Sản phẩm được tìm thấy.',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: favoriteProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];
              return ProductCard(
                imageUrl: product['imageUrl'],
                name: product['name'],
                category: product['category'],
                price: product['price'],
                discount: product['discount'],
                discountColor: product['discountColor'],
                isFavorite: true,
                onFavoriteToggle: () {
                  onFavoriteToggle(product['id']);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}