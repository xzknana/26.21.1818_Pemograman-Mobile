import 'package:flutter/material.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/action_buttons.dart';
import '../widgets/social_media_row.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Header profil: foto, nama, dan NIM
              const ProfileHeader(),

              const SizedBox(height: 24),

              // Informasi lengkap mahasiswa
              const ProfileInfo(
                name: 'Rissa Rizkika',
                nim: '26.21.1618',
                programStudi: 'S1 Informatika',
                email: 'r.rizkika@students.amikom.ac.id',
                lokasi: 'Yogyakarta, Indonesia',
              ),

              const SizedBox(height: 24),

              // Tombol aksi yang sudah dipisahkan
              const ActionButtons(),

              const SizedBox(height: 16),

              // Navigasi ke halaman AboutScreen
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Tentang Aplikasi'),
              ),

              const SizedBox(height: 24),

              // Ikon media sosial
              const SocialMediaRow(),
            ],
          ),
        ),
      ),
    );
  }
}
