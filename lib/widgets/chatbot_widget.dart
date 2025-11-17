import 'package:flutter/material.dart';

class ChatBotWidget extends StatefulWidget {
  const ChatBotWidget({super.key});

  @override
  State<ChatBotWidget> createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  bool _isOpen = false;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Chào bạn! SmartShop có thể giúp gì cho bạn?',
      'isUser': false,
    }
  ];

  final List<String> _suggestions = [
    "Giày Nike còn hàng không?", // Sửa gợi ý cho đúng kịch bản
    "Áo Hoodie còn không?",
    "Địa chỉ của shop ở đâu?",
    "Cách thức mua hàng?",
  ];

  void _handleMessage(String text) {
    if (text.trim().isEmpty) return;

    // 1. Hiện tin nhắn người dùng
    setState(() {
      _messages.add({'text': text, 'isUser': true});
    });
    _controller.clear();
    _scrollToBottom();

    // 2. Bot suy nghĩ và trả lời
    Future.delayed(const Duration(seconds: 1), () {
      String response = "Dạ em chưa hiểu rõ, anh/chị vui lòng gọi hotline 09878632607 để được hỗ trợ nhanh nhất ạ!";
      String lowerText = text.toLowerCase();

      // --- KỊCH BẢN TRẢ LỜI THÔNG MINH ---

      // Kịch bản 1: Hỏi về TỒN KHO (Còn hàng không?)
      if (lowerText.contains("còn hàng") || lowerText.contains("còn không") || lowerText.contains("còn ko")) {

        // Kiểm tra xem khách hỏi món gì
        if (lowerText.contains("nike") || lowerText.contains("giày")) {
          response = "Dạ mẫu Giày Nike Air Zoom hiện vẫn còn đủ size (38-43) tại kho ạ. \n\nAnh tham khảo chi tiết tại: \n👉 https://smartshop.vn/giay-nike-air-zoom";
        }
        else if (lowerText.contains("hoodie") || lowerText.contains("áo")) {
          response = "Dạ Áo Hoodie Essential bên em mới về thêm, vẫn còn hàng ạ. \n\nLink sản phẩm: \n👉 https://smartshop.vn/ao-hoodie-essential";
        }
        else if (lowerText.contains("đồng hồ") || lowerText.contains("casio")) {
          response = "Dạ Đồng hồ Casio Classic đang bán chạy nhưng vẫn còn hàng anh nhé. \n\nXem tại: \n👉 https://smartshop.vn/dong-ho-casio";
        }
        else if (lowerText.contains("abc")) { // Test theo ảnh của bạn
          response = "Dạ còn. Anh tham khảo tại: \nhttps://smart-shop.vn/ao-abc";
        }
        else {
          // Hỏi chung chung
          response = "Dạ sản phẩm này hiện tại vẫn đang có sẵn tại cửa hàng ạ. Anh/chị có thể đặt hàng ngay trên App nhé!";
        }
      }

      // Kịch bản 2: Hỏi địa chỉ
      else if (lowerText.contains("địa chỉ") || lowerText.contains("ở đâu")) {
        response = "Dạ shop ở 69/89 Đặng Thùy Trâm, Bình Lợi Trung, HCM ạ.";
      }
      // Kịch bản 3: Hỏi cách mua
      else if (lowerText.contains("mua") || lowerText.contains("đặt hàng")) {
        response = "Dạ đơn giản lắm ạ! Anh/chị chọn sản phẩm ưng ý, thêm vào giỏ hàng rồi bấm nút Thanh toán là được nhé.";
      }
      // Kịch bản 4: Chào hỏi
      else if (lowerText.contains("chào") || lowerText.contains("hi ") || lowerText.contains("hello")) {
        response = "SmartShop xin chào! Chúc anh/chị một ngày mua sắm thật vui vẻ ❤️";
      }

      // 3. Hiện tin nhắn Bot
      if (mounted) {
        setState(() {
          _messages.add({'text': response, 'isUser': false});
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80, // Đẩy lên cao chút để không che nút Navigation Bar
      right: 20,
      child: _isOpen ? _buildChatWindow() : _buildFloatingButton(),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () => setState(() => _isOpen = true),
      backgroundColor: const Color(0xFF0857A0),
      child: const Icon(Icons.chat, color: Colors.white),
    );
  }

  Widget _buildChatWindow() {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: Container(
        width: 320,
        height: 450,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0857A0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy, color: Colors.white),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SmartShop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('• Trực tuyến', style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                    ],
                  ),
                  const Spacer(),
                  InkWell(onTap: () => setState(() => _isOpen = false), child: const Icon(Icons.remove, color: Colors.white))
                ],
              ),
            ),

            // List tin nhắn
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['isUser'];
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Avatar Bot (Chỉ hiện nếu là Bot)
                        if (!isUser) ...[
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(0xFF0857A0),
                            child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                        ],

                        // Bong bóng chat
                        Flexible( // Dùng Flexible để tin nhắn dài tự xuống dòng
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.grey.shade200 : const Color(0xFF0857A0), // User màu xám, Bot màu xanh (như hình)
                              borderRadius: BorderRadius.circular(12).copyWith(
                                bottomLeft: !isUser ? Radius.zero : const Radius.circular(12),
                                bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              msg['text'],
                              style: TextStyle(color: isUser ? Colors.black : Colors.white), // Chữ bot màu trắng
                            ),
                          ),
                        ),

                        // Avatar User (Chỉ hiện nếu là User) - Như hình bạn gửi
                        if (isUser) ...[
                          const SizedBox(width: 6),
                          const CircleAvatar(
                            radius: 14,
                            backgroundImage: AssetImage('assets/images/icon.png'), // Thay bằng ảnh user
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),

            // Gợi ý
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: _suggestions.map((text) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(text, style: const TextStyle(fontSize: 10)),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      onPressed: () => _handleMessage(text),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),

            // Ô nhập liệu
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Soạn câu hỏi...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        filled: true, fillColor: Colors.grey.shade100,
                      ),
                      onSubmitted: _handleMessage,
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send, color: Color(0xFF0857A0)), onPressed: () => _handleMessage(_controller.text))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}