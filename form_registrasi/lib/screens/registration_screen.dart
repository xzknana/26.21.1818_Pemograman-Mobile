import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Tambahan: controller nomor telepon dan tanggal lahir
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Tambahan: state tanggal lahir, jenis kelamin, persetujuan,
  // dan kekuatan password
  DateTime? _selectedBirthDate;
  String? _selectedGender;
  bool _isAgreed = false;
  bool _showTermsError = false;
  int _passwordStrength = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // Validasi nama (kode sebelumnya)
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }

    return null;
  }

  // Validasi email (kode sebelumnya)
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  // Validasi password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung huruf kapital';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }

    return null;
  }

  // Validasi konfirmasi password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }

    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }

    return null;
  }

  // Tambahan: validasi nomor telepon
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor telepon hanya boleh berisi angka';
    }

    if (value.length < 10 || value.length > 13) {
      return 'Nomor telepon harus 10–13 digit';
    }

    return null;
  }

  // Tambahan: memilih tanggal lahir
  Future<void> _pickBirthDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Pilih Tanggal Lahir',
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _selectedBirthDate = pickedDate;
        _birthDateController.text =
            '${pickedDate.day.toString().padLeft(2, '0')}/'
            '${pickedDate.month.toString().padLeft(2, '0')}/'
            '${pickedDate.year}';
      });
    }
  }

  // Menghitung kekuatan password
  void _checkPasswordStrength(String value) {
    int strength = 0;

    if (value.isNotEmpty) {
      final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
      final hasNumber = RegExp(r'[0-9]').hasMatch(value);
      final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
      final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
      final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(value);

      if (value.length >= 8 &&
          hasUppercase &&
          hasLowercase &&
          hasNumber &&
          hasSymbol) {
        strength = 3; // Kuat
      } else if (value.length >= 8 && hasLetter && hasNumber) {
        strength = 2; // Sedang
      } else {
        strength = 1; // Lemah
      }
    }

    setState(() {
      _passwordStrength = strength;
    });
  }

  // Warna indikator password
  Color _getPasswordStrengthColor() {
    switch (_passwordStrength) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Teks indikator password
  String _getPasswordStrengthText() {
    switch (_passwordStrength) {
      case 1:
        return 'Lemah';
      case 2:
        return 'Sedang';
      case 3:
        return 'Kuat';
      default:
        return 'Belum diisi';
    }
  }

  // Handler submit form
  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _showTermsError = !_isAgreed;
    });

    // Form tidak diproses jika ada input tidak valid
    // atau syarat belum disetujui
    if (!isValid || !_isAgreed) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulasi proses registrasi
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Dialog sukses dengan informasi tambahan
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Registrasi Berhasil'),
        content: Text(
          'Selamat, ${_nameController.text}!\n'
          'Email: ${_emailController.text}\n'
          'Nomor Telepon: ${_phoneController.text}\n'
          'Tanggal Lahir: ${_birthDateController.text}\n'
          'Jenis Kelamin: $_selectedGender',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _resetForm();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Reset form
  void _resetForm() {
    _formKey.currentState?.reset();

    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _phoneController.clear();
    _birthDateController.clear();

    setState(() {
      _obscurePassword = true;
      _obscureConfirmPassword = true;
      _selectedBirthDate = null;
      _selectedGender = null;
      _isAgreed = false;
      _showTermsError = false;
      _passwordStrength = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Registrasi'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const SizedBox(height: 16),
                const Icon(
                  Icons.person_add,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isi form di bawah ini untuk mendaftar',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Field Nama 
                CustomTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap Anda',
                  prefixIcon: Icons.person,
                  validator: _validateName,
                ),

                // Field Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Masukkan email Anda',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),

                // Field Nomor Telepon (tambahan)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: 'Masukkan 10–13 digit nomor telepon',
                      prefixIcon: const Icon(Icons.phone),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: _validatePhone,
                  ),
                ),

                // Field Tanggal Lahir (tambahan)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    onTap: _pickBirthDate,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      hintText: 'Pilih tanggal lahir Anda',
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (_) {
                      if (_selectedBirthDate == null) {
                        return 'Tanggal lahir harus dipilih';
                      }
                      return null;
                    },
                  ),
                ),

                // Dropdown Jenis Kelamin
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      prefixIcon: const Icon(Icons.wc),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Laki-laki',
                        child: Text('Laki-laki'),
                      ),
                      DropdownMenuItem(
                        value: 'Perempuan',
                        child: Text('Perempuan'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jenis kelamin harus dipilih';
                      }
                      return null;
                    },
                  ),
                ),

                // Field Password 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Minimal 8 karakter, huruf kapital, angka',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        onChanged: _checkPasswordStrength,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _passwordStrength / 3,
                        minHeight: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getPasswordStrengthColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kekuatan Password: ${_getPasswordStrengthText()}',
                        style: TextStyle(
                          color: _getPasswordStrengthColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Field Konfirmasi Password
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      hintText: 'Ulangi password Anda',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                  ),
                ),

                // Checkbox Persetujuan
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _isAgreed,
                  onChanged: (value) {
                    setState(() {
                      _isAgreed = value ?? false;
                      _showTermsError = false;
                    });
                  },
                  title: const Text('Saya menyetujui syarat dan ketentuan'),
                  activeColor: Colors.deepPurple,
                ),
                if (_showTermsError && !_isAgreed)
                  const Padding(
                    padding: EdgeInsets.only(left: 12, bottom: 8),
                    child: Text(
                      'Anda harus menyetujui syarat dan ketentuan',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 24),

                // Tombol Submit
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Daftar', style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 12),

                // Tombol Reset
                OutlinedButton(
                  onPressed: _isLoading ? null : _resetForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Reset'),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
