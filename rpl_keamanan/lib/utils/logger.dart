import 'package:flutter/foundation.dart';

class Logger {
  // Constructor private agar digunakan secara static.
  Logger._();

  /// Log untuk informasi debugging.
  static void debug(String message) {
    _log('DEBUG', message);
  }

  /// Log untuk informasi umum aplikasi.
  static void info(String message) {
    _log('INFO', message);
  }

  /// Log untuk memberikan peringatan.
  static void warning(String message) {
    _log('WARNING', message);
  }

  /// Log untuk mencatat kesalahan.
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;

    debugPrint('[ERROR] $message');

    if (error != null) {
      debugPrint('  Detail: $error');
    }

    if (stackTrace != null) {
      debugPrint('  StackTrace: $stackTrace');
    }
  }

  /// Method internal untuk menampilkan log.
  static void _log(String level, String message) {
    if (!kDebugMode) return;

    debugPrint('[$level] $message');
  }
}
