import 'package:flutter/material.dart';

import 'profile_photo.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ProfilePhoto(radius: 60),
        const SizedBox(height: 16),
        const Text(
          'Rissa Rizkika',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('NIM: 26.21.1618', style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
