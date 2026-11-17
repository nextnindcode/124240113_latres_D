import 'package:flutter/material.dart';

import '../services/registration_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // Sesuaikan dengan NIM pemilik aplikasi.
  static const String correctPassword = '124240113';

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Proses pendaftaran akun.
  Future<void> handleRegister() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final username = usernameController.text.trim();

      // Simpan username menggunakan SharedPreferences.
      final success = await RegistrationService.register(username);

      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username sudah terdaftar!'),
            backgroundColor: Color(0xFFD9534F),
          ),
        );

        setState(() {
          isLoading = false;
        });

        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Color(0xFF6AB0AF),
        ),
      );

      // Kembali ke halaman Login dengan username terisi otomatis.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage(initialUsername: username)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi gagal: $e'),
          backgroundColor: const Color(0xFFD9534F),
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  const Icon(
                    Icons.celebration_rounded,
                    size: 85,
                    color: Color(0xFFE5738A),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Create Your Account!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C2A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Daftar dan mulai persiapkan pestamu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF8D6460)),
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    'Username',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C2A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: 'Buat username',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username tidak boleh kosong';
                      }

                      if (value.trim().length < 3) {
                        return 'Username minimal 3 karakter';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Password (NIM)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C2A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Masukkan NIM',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }

                      if (value != correctPassword) {
                        return 'Password harus sesuai NIM';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Konfirmasi Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C2A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Ulangi password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password tidak boleh kosong';
                      }

                      if (value != passwordController.text) {
                        return 'Konfirmasi password tidak cocok';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5738A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'REGISTER',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun?',
                        style: TextStyle(color: Color(0xFF8D6460)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login di sini',
                          style: TextStyle(
                            color: Color(0xFFE5738A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Pinkie Party Mart',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8D6460), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
