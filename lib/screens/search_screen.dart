import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'category_products_screen.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  String _searchText = "";
  final TextEditingController _controller = TextEditingController();


  final List<Map<String, dynamic>> _categories = [
    {'name': 'Thể thao', 'icon': 'assets/icons/Running.png'},
    {'name': 'Nội Thất', 'icon': 'assets/icons/Sofa.png'},
    {'name': 'Điện tử', 'icon': 'assets/icons/Cpu.png'},
    {'name': 'Quần áo', 'icon': 'assets/icons/Clothes hanger.png'},
    {'name': 'Giày', 'icon': 'assets/icons/Sneakers.png'},
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> searchResults = allProducts
        .where((p) => p['name'].toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Container(
          height: 40,
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: _controller,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Tìm kiếm',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchText.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                onPressed: () {
                  _controller.clear();
                  setState(() => _searchText = "");
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: _searchText.isEmpty
          ? _buildCategoryList()
          : _buildSearchResults(searchResults),
    );
  }

  Widget _buildCategoryList() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tìm kiếm theo danh mục", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return InkWell(
                  onTap: () {

                    Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryProductsScreen(categoryName: cat['name'])));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Image.asset(cat['icon'], width: 24, height: 24, errorBuilder: (_,__,___) => const Icon(Icons.category)),
                        const SizedBox(width: 16),
                        Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _searchText = " ");
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0857A0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("Tất cả sản phẩm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }


  Widget _buildSearchResults(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.orange), // Dùng tạm icon này hoặc ảnh
            const SizedBox(height: 20),
            const Text("Không tìm thấy sản phẩm bạn cần tìm", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _controller.clear();
                setState(() => _searchText = "");
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0857A0)),
              child: const Text("Xem tất cả", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.65),
      itemBuilder: (context, index) {
        final product = results[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
          child: ProductCard(
            imageUrl: product['imageUrl'],
            name: product['name'],
            category: product['category'],
            price: product['price'],
            discount: product['discount'],
            discountColor: product['discountColor'],
            isFavorite: false,
            onFavoriteToggle: () {},
          ),
        );
      },
    );
  }
}