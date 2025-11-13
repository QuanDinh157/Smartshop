import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


final List<Map<String, dynamic>> allProducts = [
  {
    'id': 'p1', // Thêm ID
    'imageUrl': 'assets/images/giay_nike.png',
    'name': 'Giày Nike',
    'category': 'Giày',
    'price': '8.500.000 vnđ',
    'discount': '0%',
    'discountColor': const Color(0xFFFEEA96),
  },
  {
    'id': 'p2',
    'imageUrl': 'assets/images/ao_hoodie.png',
    'name': 'Áo hoodie',
    'category': 'Quần áo',
    'price': '390.000 vnđ',
    'discount': '49%',
    'discountColor': const Color(0xFFFFD18D),
  },
  {
    'id': 'p3',
    'imageUrl': 'assets/images/dong_ho.png',
    'name': 'Đồng hồ casio',
    'category': 'Đồng hồ',
    'price': '3.200.000 vnđ',
    'discount': '0%',
    'discountColor': const Color(0xFFFEEA96),
  },
  {
    'id': 'p4',
    'imageUrl': 'assets/images/ban_phim_gaming.png',
    'name': 'Bàn phím Gaming',
    'category': 'Điện tử',
    'price': '580.000 vnđ',
    'discount': '2%',
    'discountColor': const Color(0xFFFEEA96),
  },
  {
    'id': 'p5',
    'imageUrl': 'assets/images/quan_jean.png',
    'name': 'Quần Jean',
    'category': 'Quần áo',
    'price': '750.000 vnđ',
    'discount': '10%',
    'discountColor': const Color(0xFFFFD18D),
  },
  {
    'id': 'p6',
    'imageUrl': 'assets/images/ghe_gaming.png',
    'name': 'Ghế Gaming',
    'category': 'Nội thất',
    'price': '4.500.000 vnđ',
    'discount': '0%',
    'discountColor': const Color(0xFFFEEA96),
  },
];


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Theo dõi tab đang được chọn

  // --- BẮT ĐẦU QUẢN LÝ STATE "YÊU THÍCH" ---
  // Đây là "bộ não" lưu danh sách ID sản phẩm đã được bấm tim
  final Set<String> _likedProductIds = {};

  // Hàm này được gọi khi bấm nút tim
  void _toggleFavorite(String productId) {
    setState(() {
      if (_likedProductIds.contains(productId)) {
        _likedProductIds.remove(productId); // Bỏ tim
      } else {
        _likedProductIds.add(productId); // Thêm tim
      }
    });
  }
  // --- KẾT THÚC QUẢN LÝ STATE ---


  // Danh sách các màn hình
  // Chúng ta truyền state "Yêu thích" vào các màn hình con
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách màn hình
    _screens = [
      // Index 0: Trang chủ
      _HomeScreenContent(
        likedProductIds: _likedProductIds, // Truyền ds tim
        onFavoriteToggle: _toggleFavorite, // Truyền hàm xử lý
      ),
      // Index 1: Trang yêu thích
      WishlistScreen(
        likedProductIds: _likedProductIds, // Truyền ds tim
        onFavoriteToggle: _toggleFavorite, // Truyền hàm xử lý
      ),
      // Index 2: Trang giỏ hàng (Tạm)
      const _PlaceholderScreen(title: 'Giỏ hàng'),
      // Index 3: Trang tài khoản (Tạm)
      const _PlaceholderScreen(title: 'Tài khoản'),
    ];
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Làm cho status bar (đồng hồ, pin) có màu trắng
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng
      // --- BODY ĐÃ ĐƯỢC THAY ĐỔI ---
      // Hiển thị màn hình dựa trên tab được chọn
      body: _screens[_selectedIndex],
      // --- KẾT THÚC SỬA BODY ---

      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // --- WIDGET NAV BAR TÙY CHỈNH (V2.22) ---
  Widget _buildCustomBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5), // Shadow hắt lên trên
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center, // <-- SỬA LẠI THÀNH CENTER
          children: [
            _buildNavItem(
              selectedIcon: Icons.home, // Icon khi được chọn
              unselectedIcon: Icons.home_outlined, // Icon khi không chọn
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
              selectedIcon: Icons.shopping_cart, // Sửa icon cho giống thiết kế
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

  /// WIDGET CON: Xây dựng 1 item trong Nav Bar
  Widget _buildNavItem({
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    // Icon (đen khi_Selected, xám khi_Unselected)
    final Icon icon = Icon(
      isSelected ? selectedIcon : unselectedIcon,
      color: isSelected ? Colors.black : Colors.grey.shade600,
      size: 24,
    );

    // Text (đen khi_Selected, xám khi_Unselected)
    final Text text = Text(
      label,
      style: TextStyle(
        color: isSelected ? Colors.black : Colors.grey.shade600,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );

    // Nếu được chọn (Selected) -> Hiển thị "Viên thuốc"
    if (isSelected) {
      return InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F0F5), // Nền xám nhạt (cái "viên thuốc")
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 8),
              text,
            ],
          ),
        ),
      );
    }

    // Nếu không được chọn (Unselected) -> Hiển thị Icon + Text
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        // --- XÓA PADDING Ở ĐÂY ---
        padding: const EdgeInsets.all(8), // Thêm padding chung
        color: Colors.transparent, // Không có nền
        child: Column( // Icon và Text xếp dọc
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 4), // Khoảng cách giữa icon và text
            text,
          ],
        ),
      ),
    );
  }
}
// --- KẾT THÚC NAV BAR ---


// ===================================================================
// NỘI DUNG TRANG CHỦ (ĐƯỢC TÁCH RA TỪ SCAFFOLD)
// ===================================================================

class _HomeScreenContent extends StatefulWidget {
  // Nhận 2 tham số từ _HomeScreenState
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
  // --- BẮT ĐẦU CODE MỚI CHO BANNER ---
  final PageController _pageController = PageController(); // Controller cho PageView
  int _currentPage = 0; // Theo dõi trang hiện tại của banner
  Timer? _timer; // Timer để tự động trượt banner

  // Danh sách các ảnh banner
  final List<String> _bannerImages = [
    'assets/banners/small_banner.png',
    'assets/banners/small_banner02.png', // Ví dụ (thay tên file của bạn)
    'assets/banners/small_banner03.png', // Ví dụ (thay tên file của bạn)
  ];

  @override
  void initState() {
    super.initState();
    _startBannerAutoScroll(); // Bắt đầu tự động cuộn banner
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy timer khi widget bị loại bỏ
    _pageController.dispose(); // Giải phóng PageController
    super.dispose();
  }

  // --- HÀM ĐÃ SỬA THỜI GIAN ---
  void _startBannerAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 6), (Timer timer) { // <-- SỬA TỪ 3 XUỐNG 2
      if (_currentPage < _bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Quay lại banner đầu tiên khi hết
      }
      // Đảm bảo controller vẫn còn tồn tại
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }
  // --- KẾT THÚC CODE MỚI CHO BANNER ---

  @override
  Widget build(BuildContext context) {
    // Trang chủ bây giờ nằm trong SingleChildScrollView riêng
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context), // Phần Header (Xanh + Tìm kiếm)
          _buildBody(context), // Phần Body (Banner + Sản phẩm)
        ],
      ),
    );
  }

  /// WIDGET: Xây dựng Header (Stack)
  Widget _buildHeader(BuildContext context) {
    // --- GIỮ NGUYÊN THÔNG SỐ CỦA BẠN ---
    const double headerHeight = 310.0;
    const double searchBarHeight = 100.0;

    return Container(
      // Dùng Stack để xếp chồng Thanh tìm kiếm lên Header
      child: Stack(
        clipBehavior: Clip.none, // Cho phép SearchBar tràn ra ngoài
        children: [
          // 1. Header màu xanh
          ClipPath(
            clipper: HomeClipper(), // Clipper tùy chỉnh
            child: Container(
              height: headerHeight,
              width: double.infinity,

              // --- ĐÃ ĐỔI SANG MÀU ĐƠN ---
              color: const Color(0xFF0857A0),
              // --- KẾT THÚC SỬA MÀU ---

              child: _buildHeaderContent(), // Nội dung trong header
            ),
          ),
          // 2. Thanh tìm kiếm
          Positioned(
            // Căn chỉnh thanh tìm kiếm nằm ở đường cong
            top: headerHeight - (searchBarHeight / 2) - 10,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HEADER (V2.17 - Tinh chỉnh vòng tròn) ---
  Widget _buildHeaderContent() {
    return Stack(
      clipBehavior: Clip.none, // <-- Đã sửa lỗi clip
      children: [

        // --- BẮT ĐẦU HIỆU ỨNG VÒNG TRÒN (ĐÃ SỬA) ---
        // Vòng 1 (Lớn, ngoài) - Dùng color thay vì border
        Positioned(
          top: -150,
          right: -140,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1), // DÙNG MÀU NỀN MỜ
            ),
          ),
        ),
        // Vòng 2 (Nhỏ, trong) - Dùng color thay vì border
        Positioned(
          top: 50,
          right: -110,
          child: Container(
            width: 230,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2), // DÙNG MÀU NỀN MỜ
            ),
          ),
        ),
        // --- KẾT THÚC HIỆU ỨNG VÒNG TRÒN ---

        // Nội dung chính
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16), // Thêm khoảng trống cho status bar
                // Dòng "Chào buổi sáng" và Giỏ hàng
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
                    // Icon giỏ hàng với nền tròn mờ
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
                // "Danh Mục Sản Phẩm"
                const Text(
                  'Danh Mục Sản Phẩm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                // Hàng ngang các danh mục
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _CategoryIcon(
                      imagePath: 'assets/icons/Running.png',
                      label: 'Thể Thao',
                      hasBackground: true,
                    ),
                    _CategoryIcon(
                      imagePath: 'assets/icons/Sofa.png',
                      label: 'Nội Thất',
                      hasBackground: true,
                    ),
                    _CategoryIcon(
                      imagePath: 'assets/icons/Cpu.png',
                      label: 'Điện Tử',
                      hasBackground: true,
                    ),
                    _CategoryIcon(
                      imagePath: 'assets/icons/Clothes hanger.png',
                      label: 'Quần Áo',
                      hasBackground: true,
                    ),
                    _CategoryIcon(
                      imagePath: 'assets/icons/Sneakers.png',
                      label: 'Giày',
                      hasBackground: true, // Giữ code của bạn
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
  // --- KẾT THÚC CẬP NHẬT HEADER ---

  /// WIDGET: Thanh tìm kiếm (Giữ code của bạn)
  Widget _buildSearchBar() {
    return Container(
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
        decoration: InputDecoration(
          hintText: 'Tìm kiếm',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  // --- WIDGET BODY (Giữ code của bạn) ---
  /// WIDGET: Xây dựng Body (Banner, Sản phẩm)
  Widget _buildBody(BuildContext context) {
    // Lấy dữ liệu sản phẩm (tạm thời)
    final List<Map<String, dynamic>> products = allProducts;

    return Container(
      color: Colors.white, // Nền trắng
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Thêm khoảng trống để bù cho thanh tìm kiếm
          const SizedBox(height: 40),

          // --- BẮT ĐẦU SỬA BANNER (V2.25) ---
          // 1. Banner quảng cáo với PageView.builder và indicator
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
                      // Dùng logic "thông minh" (giống _ProductCard)
                      final String imageUrl = _bannerImages[index];
                      if (imageUrl.startsWith('http')) {
                        return Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50));
                          },
                        );
                      } else {
                        return Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50));
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
              // Page indicator (các chấm)
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
                      width: _currentPage == index ? 24.0 : 8.0, // Chấm to hơn
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
          // --- KẾT THÚC SỬA BANNER ---

          const SizedBox(height: 20),

          // 2. Tiêu đề "Mục Bán Chạy"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mục Bán Chạy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // --- SỬA LẠI GRID SẢN PHẨM ---
          // Dùng GridView.builder thay vì Row
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.65, // Tỉ lệ (Rộng / Cao)
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              final String productId = product['id'];
              final bool isFavorite = widget.likedProductIds.contains(productId);

              return ProductCard(
                imageUrl: product['imageUrl'],
                name: product['name'],
                category: product['category'],
                price: product['price'],
                discount: product['discount'],
                discountColor: product['discountColor'],
                isFavorite: isFavorite, // Truyền trạng thái tim
                onFavoriteToggle: () {
                  widget.onFavoriteToggle(productId); // Gọi hàm khi bấm tim
                },
              );
            },
          ),
          // --- KẾT THÚC SỬA GRID ---

          const SizedBox(height: 20), // Thêm khoảng đệm ở dưới cùng
        ],
      ),
    );
  }
// --- KẾT THÚC CẬP NHẬT BODY ---
}


// --- WIDGET ICON (GIỮ NGUYÊN CODE CỦA BẠN) ---
/// WIDGET CON: Icon Danh mục (Thể Thao, Nội Thất,...)
class _CategoryIcon extends StatelessWidget {
  final String imagePath; // Dùng ảnh thay vì IconData
  final String label;
  final bool hasBackground; // Tùy chọn có nền hay không

  const _CategoryIcon({
    required this.imagePath,
    required this.label,
    this.hasBackground = true, // Mặc định là có nền
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50, // Kích thước cố định
          height: 50,
          padding: const EdgeInsets.all(8), // Padding cho ảnh
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
// --- KẾT THÚC CẬP NHẬT ICON ---


// ===================================================================
// BẮT ĐẦU FILE 2: WISHLIST SCREEN (TRANG YÊU THÍCH)
// ===================================================================

class WishlistScreen extends StatelessWidget {
  // Nhận 2 tham số từ HomeScreen
  final Set<String> likedProductIds;
  final Function(String) onFavoriteToggle;

  const WishlistScreen({
    super.key,
    required this.likedProductIds,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Lọc ra danh sách sản phẩm YÊU THÍCH
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
        elevation: 1, // Thêm đường viền mờ
        centerTitle: false,
      ),
      body: favoriteProducts.isEmpty
          ? _buildEmptyWishlist() // Hiển thị nếu rỗng
          : _buildWishlistGrid(favoriteProducts), // Hiển thị nếu có
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
          // Hiển thị số lượng sản phẩm được tìm thấy
          Text(
            '${favoriteProducts.length} Sản phẩm được tìm thấy.',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          // Dùng GridView.builder để tạo lưới 2 cột
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: favoriteProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 cột
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.65, // Tỉ lệ (Rộng / Cao)
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
                isFavorite: true, // 100% là true vì đây là màn hình Yêu thích
                onFavoriteToggle: () {
                  // Gọi hàm ở HomeScreen để xóa
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

// ===================================================================
// BẮT ĐẦU FILE 3: PRODUCT CARD (THẺ SẢN PHẨM)
// ===================================================================

/// WIDGET CON: Thẻ Sản phẩm (Product Card) - V3.0 (SỬA THEO THIẾT KẾ)
class ProductCard extends StatelessWidget {
  final String imageUrl, name, category, price, discount;
  final Color discountColor;

  // --- NÂNG CẤP ĐỂ XỬ LÝ "TIM" ---
  final bool isFavorite; // Trạng thái tim (đỏ hay không)
  final VoidCallback onFavoriteToggle; // Hàm gọi khi bấm tim

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.price,
    required this.discount,
    required this.discountColor,
    required this.isFavorite, // Bắt buộc
    required this.onFavoriteToggle, // Bắt buộc
  });

  @override
  Widget build(BuildContext context) {
    // --- BẮT ĐẦU LOGIC "THÔNG MINH" (V2.15) ---
    Widget imageWidget;
    if (imageUrl.startsWith('http')) {
      // Nếu là link internet (https://...)
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        height: 120,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.grey, size: 60);
        },
      );
    } else {
      // Nếu là link local (assets/...)
      imageWidget = Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        height: 120,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.grey, size: 60);
        },
      );
    }
    // --- KẾT THÚC LOGIC "THÔNG MINH" ---

    return Container(
      // 1. Thẻ Card bên ngoài
      decoration: BoxDecoration(
        color: const Color(0xFF0857A0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none, // Cho phép các nút lồi ra
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Khung ảnh bên trong
              Container(
                height: 140,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageWidget, // <-- Dùng widget "thông minh" ở đây
                ),
              ),

              // 3. Thông tin sản phẩm
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 4. Dòng Category + Dấu tick
                    Row(
                      children: [
                        Text(
                          category,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 5. Tên sản phẩm
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // 6. Giá
                    Text(
                      price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),

          // 7. Tag giảm giá (sửa màu)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: discountColor, // Dùng màu truyền vào
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                discount,
                style: const TextStyle(
                  color: Colors.black, // Chữ đen
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 8. Nút Yêu thích (ĐÃ NÂNG CẤP)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                  )
                ],
              ),
              child: IconButton(
                // Thay đổi icon dựa trên isFavorite
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey[800],
                  size: 20,
                ),
                onPressed: onFavoriteToggle, // Gọi hàm callback
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

          // 9. Nút Thêm (sửa màu và vị trí)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF333333), // Màu đen/xám đậm
                borderRadius: BorderRadius.circular(12), // Bo góc
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
          )
        ],
      ),
    );
  }
}
// --- KẾT THÚC SỬA LỖI ---


// --- MÀN HÌNH PLACEHOLDER CHO TAB 2 VÀ 3 ---
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Đây là trang $title'),
      ),
    );
  }
}

/// CLASS: CustomClipper để tạo đường cong
class HomeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Bắt đầu từ top-left
    path.lineTo(0, size.height - 50); // Đi xuống bên trái

    // Tạo đường cong lõm ở giữa
    path.quadraticBezierTo(
      size.width / 2, // Điểm control ở giữa
      size.height,      // Điểm control thấp hơn (tạo độ lõm)
      size.width,       // Điểm kết thúc bên phải
      size.height - 50, // Chiều cao kết thúc bên phải
    );

    path.lineTo(size.width, 0); // Đi lên bên phải
    path.close(); // Đóng đường path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}