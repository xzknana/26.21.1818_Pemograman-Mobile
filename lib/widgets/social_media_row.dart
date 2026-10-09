import 'package:flutter/material.dart';

class SocialMediaRow extends StatelessWidget {
  const SocialMediaRow({super.key});

  void _showMessage(BuildContext context, String socialMedia) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$socialMedia diklik'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.camera_alt),
          tooltip: 'Instagram',
          onPressed: () => _showMessage(context, 'Instagram'),
        ),
        IconButton(
          icon: const Icon(Icons.work),
          tooltip: 'LinkedIn',
          onPressed: () => _showMessage(context, 'LinkedIn'),
        ),
        IconButton(
          icon: const Icon(Icons.code),
          tooltip: 'GitHub',
          onPressed: () => _showMessage(context, 'GitHub'),
        ),
      ],
    );
  }
}
