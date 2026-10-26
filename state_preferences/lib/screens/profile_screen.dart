import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _favoriteFormKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _favoriteController;

  bool _controllersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_controllersInitialized) return;

    final provider = context.read<UserProvider>();

    _nameController = TextEditingController(text: provider.user.name);
    _emailController = TextEditingController(text: provider.user.email);
    _favoriteController = TextEditingController();

    _controllersInitialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    // Validasi input kosong
    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan email wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi format email
    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$');

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi nama dari karakter atau tag berbahaya
    final dangerousPattern = RegExp(
      r'<\s*/?\s*script\b[^>]*>|<[^>]*>',
      caseSensitive: false,
    );

    if (dangerousPattern.hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nama tidak boleh mengandung karakter atau tag berbahaya!',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi email yang sudah digunakan
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');

    final currentEmail = context.read<UserProvider>().user.email.trim();

    if (savedEmail != null &&
        savedEmail.toLowerCase() == email.toLowerCase() &&
        email.toLowerCase() != currentEmail.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email sudah digunakan! Gunakan email lain.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simpan profil melalui Provider
    try {
      final currentUser = context.read<UserProvider>().user;

      final updatedUser = currentUser.copyWith(name: name, email: email);

      await context.read<UserProvider>().updateUser(updatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan profil. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addFavorite() async {
    if (!_favoriteFormKey.currentState!.validate()) return;

    final provider = context.read<UserProvider>();
    final item = _favoriteController.text.trim();

    final alreadyExists = provider.favorites.any(
      (favorite) => favorite.toLowerCase() == item.toLowerCase(),
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item favorit sudah ada')));
      return;
    }

    try {
      await context.read<UserProvider>().addFavorite(item);

      if (!mounted) return;

      _favoriteController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorit berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan favorit'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeFavorite(String item) async {
    try {
      await context.read<UserProvider>().removeFavorite(item);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$item berhasil dihapus')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus favorit'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await context.read<UserProvider>().logout();

                if (!mounted) return;

                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal logout'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (provider.user.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Foto profil
                  const SizedBox(height: 16),
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 24),

                  // Form profil
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email tidak boleh kosong';
                            }

                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Format email tidak valid';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _saveProfile,
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan Profil'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Bagian daftar favorit
                  Text(
                    'Daftar Favorit',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Tambahkan hobi atau aktivitas favorit kamu.'),
                  const SizedBox(height: 16),

                  Form(
                    key: _favoriteFormKey,
                    child: TextFormField(
                      controller: _favoriteController,
                      decoration: const InputDecoration(
                        labelText: 'Hobi / Item Favorit',
                        hintText: 'Contoh: Membaca buku',
                        prefixIcon: Icon(Icons.favorite),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _addFavorite(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Item favorit tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: _addFavorite,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Favorit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.pink),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Favorit Saya (${provider.favorites.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (provider.favorites.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Belum ada favorit. Silakan tambahkan hobi kamu.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...provider.favorites.map(
                      (item) => Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.favorite,
                            color: Colors.pink,
                          ),
                          title: Text(item),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            tooltip: 'Hapus $item',
                            onPressed: () => _removeFavorite(item),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Catatan keamanan
                  Card(
                    color: Colors.amber[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.amber[800]),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Catatan Keamanan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Data profil dan favorit disimpan menggunakan '
                            'SharedPreferences. Data ini tidak dienkripsi. '
                            'Jangan simpan password atau informasi sensitif '
                            'di dalamnya.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
