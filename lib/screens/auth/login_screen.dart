import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/app_routes.dart';
import '../../widgets/custom_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        if (email == 'admin@gmail.com' && password == 'admin123') {
          Get.offAllNamed(AppRoutes.penggunaAdmin);
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      } on AuthException catch (e) {
        Get.snackbar(
          'Error',
          e.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Terjadi kesalahan tidak terduga',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://yveiqftpcacwvnqbxrco.supabase.co/storage/v1/object/public/berita-images/f31604ab-5389-4a01-bab8-041da6d8ac55/1750688220230.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Logo kiri atas
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40, bottom: 20),
                          child: Image.network(
                            'https://yveiqftpcacwvnqbxrco.supabase.co/storage/v1/object/public/berita-images/f31604ab-5389-4a01-bab8-041da6d8ac55/1750731646223.jpg',
                            height: 130,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 42),

                      // Email
                      CustomInputField(
                        controller: _emailController,
                        labelText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || !GetUtils.isEmail(value)) {
                            return 'Masukkan email yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      CustomInputField(
                        controller: _passwordController,
                        labelText: 'Password',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Tombol Login
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 18.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),

                      // Belum punya akun? Silahkan Daftar (tanpa underline)
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? Silahkan ',
                            style: TextStyle(color: Colors.black),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.register),
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 0, 0),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
