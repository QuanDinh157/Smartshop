import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'home_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryProductsScreen({super.key, required this.categoryName});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {

  late List<Map<String, dynamic>> _originalProducts;


  late List<Map<String, dynamic>> _displayedProducts;

  // Trạng thái bộ lọc
  String _sortOption = 'none';
  String _filterOption = 'all';

  @override
  void initState() {
    super.initState();


    _originalProducts = allProducts.where((product) {
      String pCat = product['category'].toString().toLowerCase().trim();
      String cName = widget.categoryName.toLowerCase().trim();
      return pCat == cName;
    }).toList();


    _displayedProducts = List.from(_originalProducts);
  }


  double _parsePrice(String priceStr) {

    return double.tryParse(priceStr.replaceAll('.', '').replaceAll(' vnđ', '')) ?? 0;
  }


  void _applyFilter() {
    setState(() {
      List<Map<String, dynamic>> temp = List.from(_originalProducts);

      // B2: Lọc theo khoảng giá
      if (_filterOption == 'under1m') {
        temp = temp.where((p) => _parsePrice(p['price']) < 1000000).toList();
      } else if (_filterOption == '1m_to_5m') {
        temp = temp.where((p) {
          double price = _parsePrice(p['price']);
          return price >= 1000000 && price <= 5000000;
        }).toList();
      } else if (_filterOption == 'over5m') {
        temp = temp.where((p) => _parsePrice(p['price']) > 5000000).toList();
      }

      // B3: Sắp xếp
      if (_sortOption == 'asc') {
        temp.sort((a, b) => _parsePrice(a['price']).compareTo(_parsePrice(b['price'])));
      } else if (_sortOption == 'desc') {
        temp.sort((a, b) => _parsePrice(b['price']).compareTo(_parsePrice(a['price'])));
      }

      _displayedProducts = temp;
    });
  }


  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder( // Để cập nhật UI bên trong BottomSheet
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 450,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bộ Lọc & Sắp Xếp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          // Reset bộ lọc
                          setModalState(() {
                            _sortOption = 'none';
                            _filterOption = 'all';
                          });
                          _applyFilter(); // Apply ra màn hình chính
                          Navigator.pop(context);
                        },
                        child: const Text('Đặt lại', style: TextStyle(color: Colors.red)),
                      )
                    ],
                  ),
                  const Divider(),

                  const Text('Sắp xếp theo giá', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildChoiceChip(setModalState, 'Giá thấp -> cao', 'asc', _sortOption, (val) => _sortOption = val),
                      _buildChoiceChip(setModalState, 'Giá cao -> thấp', 'desc', _sortOption, (val) => _sortOption = val),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text('Khoảng giá', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildChoiceChip(setModalState, 'Tất cả', 'all', _filterOption, (val) => _filterOption = val),
                      _buildChoiceChip(setModalState, 'Dưới 1 triệu', 'under1m', _filterOption, (val) => _filterOption = val),
                      _buildChoiceChip(setModalState, '1 - 5 triệu', '1m_to_5m', _filterOption, (val) => _filterOption = val),
                      _buildChoiceChip(setModalState, 'Trên 5 triệu', 'over5m', _filterOption, (val) => _filterOption = val),
                    ],
                  ),

                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      _applyFilter(); // Áp dụng thay đổi
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0857A0),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Áp dụng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChoiceChip(
      StateSetter setModalState,
      String label,
      String value,
      String groupValue,
      Function(String) onSelected
      ) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF0857A0).withOpacity(0.2),
      labelStyle: TextStyle(color: isSelected ? const Color(0xFF0857A0) : Colors.black),
      onSelected: (bool selected) {
        if (selected) {
          setModalState(() {
            onSelected(value);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.categoryName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- THANH BỘ LỌC ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell( // Dùng InkWell để bắt sự kiện bấm
              onTap: _showFilterBottomSheet,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.filter_list, size: 20),
                        const SizedBox(width: 8),
                        Text(_filterOption == 'all' && _sortOption == 'none' ? "Bộ lọc" : "Đang lọc...", style: TextStyle(fontWeight: FontWeight.bold, color: (_filterOption != 'all' || _sortOption != 'none') ? const Color(0xFF0857A0) : Colors.black))
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down)
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: _displayedProducts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text("Không có sản phẩm nào trong\n'${widget.categoryName}'", textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                  if (_filterOption != 'all')
                    TextButton(onPressed: () {
                      setState(() {
                        _sortOption = 'none';
                        _filterOption = 'all';
                        _applyFilter();
                      });
                    }, child: const Text("Xóa bộ lọc", style: TextStyle(color: Color(0xFF0857A0))))
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _displayedProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final product = _displayedProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
                  },
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
            ),
          ),
        ],
      ),
    );
  }
}