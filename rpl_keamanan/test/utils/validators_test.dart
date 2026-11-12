
import 'package:flutter_test/flutter_test.dart';
import '../../lib/utils/validators.dart';

void main() {
  // ==========================================
  // TEST isValidEmail()
  // ==========================================
  group('isValidEmail()', () {
    test('Email dengan format benar harus valid', () {
      expect(Validators.isValidEmail('user@gmail.com'), true);
      expect(Validators.isValidEmail('test123@yahoo.com'), true);
      expect(Validators.isValidEmail('nama.user@domain.co.id'), true);
    });

    test('Email tanpa tanda @ harus tidak valid', () {
      expect(Validators.isValidEmail('usergmail.com'), false);
    });

    test('Email tanpa domain harus tidak valid', () {
      expect(Validators.isValidEmail('user@'), false);
    });

    test('Email tanpa ekstensi domain harus tidak valid', () {
      expect(Validators.isValidEmail('user@gmail'), false);
    });

    test('Email kosong harus tidak valid', () {
      expect(Validators.isValidEmail(''), false);
    });

    test('Email dengan spasi di awal dan akhir tetap valid', () {
      expect(Validators.isValidEmail(' user@gmail.com '), true);
    });
  });

  // ==========================================
  // TEST sanitize()
  // ==========================================
  group('sanitize()', () {
    test('Karakter HTML harus diubah menjadi HTML entity', () {
      const input = '<script>alert("XSS")</script>';

      final result = Validators.sanitize(input);

      expect(
        result,
        '&lt;script&gt;alert(&quot;XSS&quot;)&lt;/script&gt;',
      );
    });

    test('Karakter ampersand harus diubah', () {
      expect(
        Validators.sanitize('Tom & Jerry'),
        'Tom &amp; Jerry',
      );
    });

    test('Tanda kutip tunggal harus diubah', () {
      expect(
        Validators.sanitize("User's profile"),
        'User&#x27;s profile',
      );
    });

    test('Tanda kutip ganda harus diubah', () {
      expect(
        Validators.sanitize('"Hello World"'),
        '&quot;Hello World&quot;',
      );
    });

    test('Input dengan karakter berbahaya harus disanitasi', () {
      const input = '<img src=x onerror="alert(1)">';

      final result = Validators.sanitize(input);

      expect(
        result,
        '&lt;img src=x onerror=&quot;alert(1)&quot;&gt;',
      );
    });

    test('Input kosong menghasilkan string kosong', () {
      expect(Validators.sanitize(''), '');
    });
  });

  // ==========================================
  // TEST validateText()
  // ==========================================
  group('validateText()', () {
    test('Input teks yang valid harus berhasil', () {
      expect(
        Validators.validateText('Rissa'),
        null,
      );
    });

    test('Input kosong harus menghasilkan error', () {
      expect(
        Validators.validateText(''),
        'Field tidak boleh kosong',
      );
    });

    test('Input hanya berisi spasi harus menghasilkan error', () {
      expect(
        Validators.validateText('   '),
        'Field tidak boleh kosong',
      );
    });

    test('Input sesuai panjang minimum harus valid', () {
      expect(
        Validators.validateText(
          'ABC',
          minLength: 3,
          maxLength: 10,
        ),
        null,
      );
    });

    test('Input sesuai panjang maksimum harus valid', () {
      expect(
        Validators.validateText(
          'ABCDEFGHIJ',
          minLength: 3,
          maxLength: 10,
        ),
        null,
      );
    });

    test('Input kurang dari panjang minimum harus tidak valid', () {
      expect(
        Validators.validateText(
          'AB',
          minLength: 3,
          maxLength: 10,
        ),
        'Field harus antara 3-10 karakter',
      );
    });

    test('Input melebihi panjang maksimum harus tidak valid', () {
      expect(
        Validators.validateText(
          'ABCDEFGHIJK',
          minLength: 3,
          maxLength: 10,
        ),
        'Field harus antara 3-10 karakter',
      );
    });

    test('Nama field dapat disesuaikan', () {
      expect(
        Validators.validateText(
          '',
          fieldName: 'Nama',
        ),
        'Nama tidak boleh kosong',
      );
    });

    test('Spasi di awal dan akhir tidak dihitung dalam panjang teks', () {
      expect(
        Validators.validateText(
          '  ABC  ',
          minLength: 3,
          maxLength: 3,
        ),
        null,
      );
    });
  });
}
