import 'package:flutter/material.dart';
import '../services/account_services.dart'; // Import file service vừa tạo

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _controller = TextEditingController();
  final _service = AccountServices();
  bool _isLoading = false;

  void _submit() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    await _service.sendFeedback(context: context, content: _controller.text.trim());
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gửi Góp Ý")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Ý kiến của bạn giúp chúng tôi phát triển hơn:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Nhập nội dung...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0857A0), foregroundColor: Colors.white),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("GỬI NGAY"),
              ),
            )
          ],
        ),
      ),
    );
  }
}