import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserProvider extends InheritedWidget {
  final User user;
  final Future<void> Function(User) updateUser;
  final Future<void> Function() logout;
  final bool isLoading;
  final bool isDarkMode;
  final Future<void> Function() toggleTheme;
  final int visitCount;
  final List<String> favorites;
  final Future<void> Function(String) addFavorite;
  final Future<void> Function(String) removeFavorite;

  const UserProvider({
    super.key,
    required this.user,
    required this.updateUser,
    required this.logout,
    required this.isLoading,
    required this.isDarkMode,
    required this.toggleTheme,
    required super.child,
    required this.visitCount,
    required this.favorites,
    required this.addFavorite,
    required this.removeFavorite,
  });

  static UserProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<UserProvider>();

    assert(provider != null, 'UserProvider tidak ditemukan di context');

    return provider!;
  }

  @override
  bool updateShouldNotify(UserProvider oldWidget) {
    return oldWidget.user != user ||
        oldWidget.isLoading != isLoading ||
        oldWidget.isDarkMode != isDarkMode ||
        oldWidget.visitCount != visitCount ||
        oldWidget.favorites != favorites;
  }
}

class UserProviderWrapper extends StatefulWidget {
  final Widget child;

  const UserProviderWrapper({super.key, required this.child});

  @override
  State<UserProviderWrapper> createState() => _UserProviderWrapperState();
}

class _UserProviderWrapperState extends State<UserProviderWrapper> {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Memuat data user dan preferensi tema.
  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final name = prefs.getString('user_name') ?? '';
      final email = prefs.getString('user_email') ?? '';
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      final favorites = prefs.getStringList('favorites') ?? [];

      // Menghitung jumlah kunjungan aplikasi.
      final previousVisitCount = prefs.getInt('visit_count') ?? 0;
      final newVisitCount = previousVisitCount + 1;

      await prefs.setInt('visit_count', newVisitCount);

      if (!mounted) return;

      setState(() {
        _user = User(name: name, email: email, isLoggedIn: isLoggedIn);
        _isDarkMode = isDarkMode;
        _visitCount = newVisitCount;
        _isLoading = false;
        _favorites = favorites;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint('Gagal memuat data user atau counter: $e');
    }
  }

  // Mengubah dan menyimpan preferensi tema.
  Future<void> _toggleTheme() async {
    final newValue = !_isDarkMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', newValue);

      if (!mounted) return;

      setState(() {
        _isDarkMode = newValue;
      });
    } catch (e) {
      debugPrint('Gagal menyimpan preferensi tema: $e');
    }
  }

  // Menyimpan data user.
  Future<void> _updateUser(User newUser) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('user_name', newUser.name);
      await prefs.setString('user_email', newUser.email);
      await prefs.setBool('is_logged_in', newUser.isLoggedIn);

      if (!mounted) return;

      setState(() {
        _user = newUser;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint('Gagal memperbarui data user: $e');
      rethrow;
    }
  }

  // Logout: menghapus nama dan status login, email tetap disimpan.
  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('user_name');
      await prefs.setBool('is_logged_in', false);

      if (!mounted) return;

      setState(() {
        _user = _user.copyWith(name: '', isLoggedIn: false);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint('Gagal logout: $e');
      rethrow;
    }
  }

  Future<void> _addFavorite(String item) async {
    final value = item.trim();

    if (value.isEmpty) return;

    // Hindari item duplikat.
    if (_favorites.any(
      (favorite) => favorite.toLowerCase() == value.toLowerCase(),
    )) {
      return;
    }

    final updatedFavorites = [..._favorites, value];
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('favorites', updatedFavorites);

    if (!mounted) return;

    setState(() {
      _favorites = updatedFavorites;
    });
  }

  Future<void> _removeFavorite(String item) async {
    final updatedFavorites = _favorites
        .where((favorite) => favorite != item)
        .toList();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('favorites', updatedFavorites);

    if (!mounted) return;

    setState(() {
      _favorites = updatedFavorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return UserProvider(
      user: _user,
      updateUser: _updateUser,
      logout: _logout,
      isLoading: _isLoading,
      isDarkMode: _isDarkMode,
      toggleTheme: _toggleTheme,
      visitCount: _visitCount,

      // Fitur daftar favorit
      favorites: _favorites,
      addFavorite: _addFavorite,
      removeFavorite: _removeFavorite,

      child: widget.child,
    );
  }
}
