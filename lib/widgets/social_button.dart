import 'package:flutter/material.dart';

class SocialButtonRow extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onFacebookPressed;
  final VoidCallback onApplePressed;
  const SocialButtonRow({
    super.key,
    required this.onGooglePressed,
    required this.onFacebookPressed,
    required this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton('assets/images/google.png'),
        const SizedBox(width: 20),
        _circleButton('assets/images/facebook.png'),
        const SizedBox(width: 20),
        const Icon(Icons.apple, size: 36),
      ],
    );
  }

  Widget _circleButton(String path) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(path),
      ),
    );
  }
}
