import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;
  List<String> get favorites => List.unmodifiable(_favorites);

  // Memuat data user, tema, favorit, dan menghitung kunjungan.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final name = prefs.getString('user_name') ?? '';
      final email = prefs.getString('user_email') ?? '';
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final darkMode = prefs.getBool('is_dark_mode') ?? false;
      final favorites = prefs.getStringList('favorites') ?? [];

      final visits = (prefs.getInt('visit_count') ?? 0) + 1;
      await prefs.setInt('visit_count', visits);

      _user = User(name: name, email: email, isLoggedIn: isLoggedIn);
      _isDarkMode = darkMode;
      _favorites = favorites;
      _visitCount = visits;
    } catch (e) {
      debugPrint('Gagal memuat data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menyimpan profil.
  Future<void> updateUser(User newUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('user_name', newUser.name);
      await prefs.setString('user_email', newUser.email);
      await prefs.setBool('is_logged_in', newUser.isLoggedIn);

      _user = newUser;
    } catch (e) {
      debugPrint('Gagal memperbarui profil: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('user_name');
      await prefs.setBool('is_logged_in', false);

      _user = _user.copyWith(name: '', isLoggedIn: false);
    } catch (e) {
      debugPrint('Gagal logout: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mengganti dan menyimpan tema.
  Future<void> toggleTheme() async {
    final newValue = !_isDarkMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', newValue);

    _isDarkMode = newValue;
    notifyListeners();
  }

  // Menambahkan favorit.
  Future<void> addFavorite(String item) async {
    final value = item.trim();
    if (value.isEmpty) return;

    final exists = _favorites.any(
      (favorite) => favorite.toLowerCase() == value.toLowerCase(),
    );

    if (exists) return;

    final updatedFavorites = [..._favorites, value];
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('favorites', updatedFavorites);

    _favorites = updatedFavorites;
    notifyListeners();
  }

  // Menghapus favorit.
  Future<void> removeFavorite(String item) async {
    final updatedFavorites = _favorites
        .where((favorite) => favorite != item)
        .toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', updatedFavorites);

    _favorites = updatedFavorites;
    notifyListeners();
  }
}
