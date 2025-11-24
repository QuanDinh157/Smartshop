import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Thư viện lưu lịch sử
import 'package:firebase_auth/firebase_auth.dart';     // Thư viện lấy User ID

class ChatBotWidget extends StatefulWidget {
  const ChatBotWidget({super.key});

  @override
  State<ChatBotWidget> createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  bool _isOpen = false; // Trạng thái mở/đóng khung chat
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Danh sách tin nhắn hiển thị trên màn hình
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Chào bạn! SmartShop có thể giúp gì cho bạn hôm nay?',
      'isUser': false,
    }
  ];

  // Gợi ý câu hỏi (Bấm vào là hỏi luôn cho nhanh)
  final List<String> _suggestions = [
    "Shop ở đâu?",
    "Giày Nike còn hàng không?",
    "Chính sách bảo hành?",
    "Phí ship thế nào?",
  ];

  // --- BỘ NÃO CỦA BOT (Kịch bản trả lời) ---
  // Bạn có thể thêm bao nhiêu câu tùy thích vào đây
  final Map<String, String> _botKnowledge = {
    'giày': 'Dạ các mẫu giày Nike, Sneaker bên em vẫn còn đủ size từ 38-44 ạ. Anh/chị đang quan tâm mẫu nào cụ thể không ạ?',
    'nike': 'Giày Nike bên em đang có chương trình giảm giá 20%. Hàng chính hãng 100%, bao check trọn đời ạ.',
    'áo': 'Áo Hoodie và áo thun bên em đang có chương trình mua 2 giảm 10%. Anh/chị ghé mục "Quần áo" xem thêm nhé!',
    'địa chỉ': 'Shop SmartShop nằm tại 69/89 Đặng Thùy Trâm, Bình Lợi, Bình Thạnh, TP.HCM. Mở cửa từ 8h - 22h ạ!',
    'ở đâu': 'Shop SmartShop nằm tại 69/89 Đặng Thùy Trâm, Bình Lợi, Bình Thạnh, TP.HCM. Mở cửa từ 8h - 22h ạ!',
    'ship': 'Bên em freeship nội thành HCM cho đơn từ 500k. Các tỉnh khác phí ship đồng giá 30k ạ.',
    'giao hàng': 'Thời gian giao hàng nội thành là 1-2 ngày, ngoại thành 3-4 ngày ạ.',
    'thanh toán': 'Shop hỗ trợ thanh toán khi nhận hàng (COD) hoặc chuyển khoản ngân hàng/Ví điện tử ạ.',
    'bảo hành': 'Sản phẩm giày được bảo hành keo chỉ 6 tháng. Đổi trả trong vòng 7 ngày nếu chưa qua sử dụng ạ.',
    'xin chào': 'Dạ chào anh/chị! Em là trợ lý ảo SmartShop. Em có thể giúp gì cho mình ạ?',
    'hi': 'Dạ chào anh/chị! Em là trợ lý ảo SmartShop. Em có thể giúp gì cho mình ạ?',
    'cảm ơn': 'Dạ không có chi ạ! Chúc anh/chị mua sắm vui vẻ tại SmartShop!',
  };

  // --- HÀM XỬ LÝ TIN NHẮN ---
  void _handleMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Hiện tin nhắn người dùng ngay lập tức
    setState(() {
      _messages.add({'text': text, 'isUser': true});
    });
    _controller.clear();
    _scrollToBottom();

    // 2. Gửi lên Firebase (Lưu lịch sử để báo cáo)
    // Phần này chạy ngầm, không ảnh hưởng việc trả lời
    try {
      final user = FirebaseAuth.instance.currentUser;
      FirebaseFirestore.instance.collection('chat_logs').add({
        'question': text,
        'userId': user?.uid ?? 'guest',
        'email': user?.email ?? 'Khách vãng lai',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Lỗi lưu chat (không sao, vẫn trả lời được): $e");
    }

    // 3. BOT SUY NGHĨ VÀ TRẢ LỜI
    Future.delayed(const Duration(seconds: 1), () {
      String userQuestion = text.toLowerCase(); // Đưa về chữ thường để dễ so sánh
      String botAnswer = "";

      // Logic tìm từ khóa (Keyword Matching)
      // Quét xem câu hỏi có chứa từ khóa nào trong bộ não không
      for (var key in _botKnowledge.keys) {
        if (userQuestion.contains(key)) {
          botAnswer = _botKnowledge[key]!;
          break; // Tìm thấy là dừng ngay, trả lời luôn
        }
      }

      // Nếu không tìm thấy từ khóa nào -> Trả lời mặc định khéo léo
      if (botAnswer.isEmpty) {
        botAnswer = "Dạ câu hỏi này hơi khó, em chưa rõ lắm. Anh/chị vui lòng để lại SĐT hoặc chat Zalo 0988.888.888 để nhân viên tư vấn kỹ hơn ạ!";
      }

      if (mounted) {
        setState(() {
          _messages.add({'text': botAnswer, 'isUser': false});
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
      bottom: 20, // Cách đáy màn hình 20px
      right: 20,  // Cách phải màn hình 20px
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // KHUNG CHAT (Chỉ hiện khi _isOpen = true)
          if (_isOpen)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: 300, // Chiều rộng khung chat
              height: 400, // Chiều cao khung chat
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 1. Header (Tiêu đề)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0857A0),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.support_agent, size: 18, color: Color(0xFF0857A0)),
                            ),
                            SizedBox(width: 8),
                            Text('Trợ lý ảo SmartShop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        InkWell(
                          onTap: () => setState(() => _isOpen = false),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        )
                      ],
                    ),
                  ),

                  // 2. List tin nhắn (Nội dung chat)
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg['isUser'];
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isUser ? const Color(0xFF0857A0) : Colors.grey.shade200,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                                bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              msg['text'],
                              style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 13),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 3. Gợi ý câu hỏi nhanh
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
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

                  // 4. Ô nhập liệu
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Hỏi gì đó...',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                              filled: true, fillColor: Colors.grey.shade100,
                            ),
                            onSubmitted: _handleMessage, // Bấm Enter trên phím ảo cũng gửi
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.send, color: Color(0xFF0857A0)),
                            onPressed: () => _handleMessage(_controller.text)
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // NÚT TRÒN (Floating Button) ĐỂ MỞ CHAT
          FloatingActionButton(
            backgroundColor: const Color(0xFF0857A0),
            child: Icon(_isOpen ? Icons.keyboard_arrow_down : Icons.chat_bubble_outline),
            onPressed: () {
              setState(() {
                _isOpen = !_isOpen;
              });
            },
          ),
        ],
      ),
    );
  }
}