import '../models/user.dart';
import '../services/api_service.dart';
import 'user_repository.dart';

/// Implementasi konkret dari UserRepository.
///
/// Class ini menggunakan ApiService untuk mengambil data User dari API.
class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;

  // Constructor dengan dependency injection.
  UserRepositoryImpl({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Mengambil seluruh data User dari API.
  @override
  Future<List<User>> getUsers() async {
    return await _apiService.getUsers();
  }

  /// Mengambil data User berdasarkan ID.
  @override
  Future<User> getUserById(int id) async {
    return await _apiService.getUserById(id);
  }

  /// Menutup resource yang digunakan oleh ApiService.
  void dispose() {
    _apiService.dispose();
  }
}
