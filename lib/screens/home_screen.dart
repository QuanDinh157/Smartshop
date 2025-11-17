import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- IMPORT CÁC WIDGET & SCREEN KHÁC ---
import '../widgets/product_card.dart';    // Thẻ sản phẩm
import '../widgets/chatbot_widget.dart';  // <--- MỚI: Chatbot Widget
import 'wishlist_screen.dart';            // Màn hình yêu thích
import 'product_detail_screen.dart';      // Màn hình chi tiết
import 'cart_screen.dart';                // Màn hình giỏ hàng
import 'profile_screen.dart';             // Màn hình User Info
import 'search_screen.dart';              // Màn hình tìm kiếm

// Dữ liệu mẫu (Đã chuẩn hóa Category cho khớp với Search)
final List<Map<String, dynamic>> allProducts = [
  {
    'id': 'p1',
    'imageUrl': 'assets/images/giay_nike.png',
    'name': 'Giày Nike Air Zoom',
    'category': 'Thể thao',
    'price': '8.500.000 vnđ',
    'discount': '0%',
    'discountColor': const Color(0xFFFEEA96),
    'description': 'Dòng giày chạy bộ Nike Air Zoom huyền thoại mang lại độ nảy và êm ái tối đa. Công nghệ đệm khí Zoom Air giúp phản hồi lực cực tốt.',
  },
  {
    'id': 'p2',
    'imageUrl': 'assets/images/ao_hoodie.png',
    'name': 'Áo Hoodie Essential',
    'category': 'Quần áo',
    'price': '390.000 vnđ',
    'discount': '49%',
    'discountColor': const Color(0xFFFFD18D),
    'description': 'Áo hoodie form rộng (Oversize), chất liệu nỉ bông cotton 100% dày dặn, ấm áp nhưng vẫn thoáng mát. Thiết kế mũ trùm đầu 2 lớp đứng form.',
  },
  {
    'id': 'p3',
    'imageUrl': 'assets/images/dong_ho.png',
    'name': 'Đồng hồ Casio Classic',
    'category': 'Điện tử',
    'price': '3.200.000 vnđ',
    'discount': '0%',
    'discountColor': const Color(0xFFFEEA96),
    'description': 'Thiết kế cổ điển vượt thời gian, biểu tượng của sự bền bỉ. Mặt kính khoáng chống trầy xước, khả năng chống nước 5ATM.',
  },
  {
    'id': 'p4',
    'imageUrl': 'assets/images/ban_phim_gaming.png',
    'name': 'Bàn phím Gaming RGB',
    'category': 'Điện tử',
    'price': '580.000 vnđ',
    'discount': '2%',
    'discountColor': const Color(0xFFFEEA96),
    'description': 'Bàn phím cơ sử dụng Blue Switch cho cảm giác gõ tách tách sướng tay. Hệ thống đèn LED RGB 16 triệu màu.',
  },
  {
    'id': 'p5',
    'imageUrl': 'assets/images/quan_jean.png',
    'name': 'Quần Jean Slimfit',
    'category': 'Quần áo',
    'price': '750.000 vnđ',
    'discount': '10%',
    'discountColor': const Color(0xFFFFD18D),
    'description': 'Quần Jean nam dáng Slimfit ôm vừa vặn, tôn dáng người mặc. Chất liệu Denim cao cấp co giãn nhẹ.',
  },
  {
    'id': 'p6',
    'imageUrl': 'assets/images/ghe_gaming.png',
    'name': 'Ghế Gaming Ergonomic',
    'category': 'Nội Thất',
    'price': '4.500.000 vnđ',
    'discount': '0%',
    'discountColor': const Color(0xFFFEEA96),
    'description': 'Ghế Gaming thiết kế chuẩn công thái học bảo vệ cột sống game thủ. Đệm mút đúc nguyên khối êm ái, bọc da PU cao cấp.',
  },
  {
    'id': 'p7',
    'imageUrl': 'assets/images/giay_nike.png',
    'name': 'Giày Sneaker Basic',
    'category': 'Giày',
    'price': '1.200.000 vnđ',
    'discount': '5%',
    'discountColor': const Color(0xFFFFD18D),
    'description': 'Giày sneaker đơn giản, dễ phối đồ, phù hợp đi học đi chơi.',
  },
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final Set<String> _likedProductIds = {};

  void _toggleFavorite(String productId) {
    setState(() {
      if (_likedProductIds.contains(productId)) {
        _likedProductIds.remove(productId);
      } else {
        _likedProductIds.add(productId);
      }
    });
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      // Tab 0: Trang chủ
      _HomeScreenContent(
        likedProductIds: _likedProductIds,
        onFavoriteToggle: _toggleFavorite,
      ),
      // Tab 1: Yêu thích
      WishlistScreen(
        likedProductIds: _likedProductIds,
        onFavoriteToggle: _toggleFavorite,
      ),
      // Tab 2: Giỏ hàng
      const CartScreen(),
      // Tab 3: Tài khoản
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: Colors.white,
      // --- SỬA Ở ĐÂY: Dùng Stack để đè ChatBot lên trên ---
      body: Stack(
        children: [
          // Lớp dưới: Nội dung chính (Home, Cart, Profile...)
          _screens[_selectedIndex],

          // Lớp trên: ChatBot Widget (Luôn nổi)
          const ChatBotWidget(),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(
              selectedIcon: Icons.home,
              unselectedIcon: Icons.home_outlined,
              label: 'Home',
              index: 0,
            ),
            _buildNavItem(
              selectedIcon: Icons.favorite,
              unselectedIcon: Icons.favorite_border,
              label: 'Yêu thích',
              index: 1,
            ),
            _buildNavItem(
              selectedIcon: Icons.shopping_cart,
              unselectedIcon: Icons.shopping_cart_outlined,
              label: 'Giỏ hàng',
              index: 2,
            ),
            _buildNavItem(
              selectedIcon: Icons.person,
              unselectedIcon: Icons.person_outline,
              label: 'Tài khoản',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    final Icon icon = Icon(
      isSelected ? selectedIcon : unselectedIcon,
      color: isSelected ? Colors.black : Colors.grey.shade600,
      size: 24,
    );
    final Text text = Text(
      label,
      style: TextStyle(
        color: isSelected ? Colors.black : Colors.grey.shade600,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );

    if (isSelected) {
      return InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F0F5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [icon, const SizedBox(width: 8), text],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [icon, const SizedBox(height: 4), text],
        ),
      ),
    );
  }
}

// --- NỘI DUNG TRANG CHỦ ---
class _HomeScreenContent extends StatefulWidget {
  final Set<String> likedProductIds;
  final Function(String) onFavoriteToggle;

  const _HomeScreenContent({
    required this.likedProductIds,
    required this.onFavoriteToggle,
  });

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _bannerImages = [
    'assets/banners/small_banner.png',
    'assets/banners/small_banner02.png',
    'assets/banners/small_banner03.png',
  ];

  @override
  void initState() {
    super.initState();
    _startBannerAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 6), (Timer timer) {
      if (_currentPage < _bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context),
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const double headerHeight = 310.0;
    const double searchBarHeight = 100.0;

    return Container(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: HomeClipper(),
            child: Container(
              height: headerHeight,
              width: double.infinity,
              color: const Color(0xFF0857A0),
              child: _buildHeaderContent(),
            ),
          ),
          Positioned(
            top: headerHeight - (searchBarHeight / 2) - 10,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -150,
          right: -140,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: -110,
          child: Container(
            width: 230,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chào Buổi Sáng',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          'SmartShop',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Danh Mục Sản Phẩm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _CategoryIcon(imagePath: 'assets/icons/Running.png', label: 'Thể Thao'),
                    _CategoryIcon(imagePath: 'assets/icons/Sofa.png', label: 'Nội Thất'),
                    _CategoryIcon(imagePath: 'assets/icons/Cpu.png', label: 'Điện Tử'),
                    _CategoryIcon(imagePath: 'assets/icons/Clothes hanger.png', label: 'Quần Áo'),
                    _CategoryIcon(imagePath: 'assets/icons/Sneakers.png', label: 'Giày'),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
      },
      child: Container(
        height: 55.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm',
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final List<Map<String, dynamic>> products = allProducts;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _bannerImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final String imageUrl = _bannerImages[index];
                      if (imageUrl.startsWith('http')) {
                        return Image.network(imageUrl, fit: BoxFit.cover);
                      } else {
                        return Image.asset(imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey));
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _bannerImages.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: _currentPage == index ? 24.0 : 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? const Color(0xFF0857A0) : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mục Bán Chạy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              final String productId = product['id'];
              final bool isFavorite = widget.likedProductIds.contains(productId);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                child: ProductCard(
                  imageUrl: product['imageUrl'],
                  name: product['name'],
                  category: product['category'],
                  price: product['price'],
                  discount: product['discount'],
                  discountColor: product['discountColor'],
                  isFavorite: isFavorite,
                  onFavoriteToggle: () {
                    widget.onFavoriteToggle(productId);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// --- CÁC WIDGET CON ---
class _CategoryIcon extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool hasBackground;

  const _CategoryIcon({
    required this.imagePath,
    required this.label,
    this.hasBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: hasBackground ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            imagePath,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error_outline, color: hasBackground ? Colors.red : Colors.white);
            },
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class HomeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}