import 'package:flutter/material.dart';

/// WIDGET CON: Thẻ Sản phẩm (Product Card) - V3.0 (SỬA THEO THIẾT KẾ)
/// Tách ra file riêng để dùng chung
class ProductCard extends StatelessWidget {
  final String imageUrl, name, category, price, discount;
  final Color discountColor; // Thêm màu cho tag

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