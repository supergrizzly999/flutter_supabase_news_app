import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../widgets/custom_input_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  String? _gender;
  DateTime? _birthdate;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _selectBirthdate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _birthdate = picked);
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate() && _birthdate != null && _gender != null) {
      setState(() => _isLoading = true);
      try {
        final AuthResponse res = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {'username': _usernameController.text.trim()},
        );

        if (res.user != null) {
          await supabase.from('profiles').insert({
            'id': res.user!.id,
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'gender': _gender,
            'birthdate': _birthdate!.toIso8601String(),
          });
        }

        if (mounted) {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Berhasil'),
              content: const Text('Pendaftaran berhasil! Silakan login.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.off(() => const LoginScreen());
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } on AuthException catch (e) {
        Get.snackbar('Error', e.message, backgroundColor: Colors.red, colorText: Colors.white);
      } catch (e) {
        Get.snackbar('Error', 'Terjadi kesalahan: $e', backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (_birthdate == null) {
        Get.snackbar('Error', 'Tanggal lahir harus diisi', backgroundColor: Colors.red, colorText: Colors.white);
      } else if (_gender == null) {
        Get.snackbar('Error', 'Jenis kelamin harus dipilih', backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.network(
              'https://yveiqftpcacwvnqbxrco.supabase.co/storage/v1/object/public/berita-images/f31604ab-5389-4a01-bab8-041da6d8ac55/1750688220230.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Tombol kembali
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(255, 0, 0, 1), size: 30),
              onPressed: () => Get.back(),
            ),
          ),

          // Gambar kanan atas
          Positioned(
            top: 5,
            right: 20,
            child: SizedBox(
              width: 180,
              height: 180,
              child: Image.network(
                'https://yveiqftpcacwvnqbxrco.supabase.co/storage/v1/object/public/berita-images/f31604ab-5389-4a01-bab8-041da6d8ac55/1750731646223.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 80),
                          const Text(
                            "Buat Akun Baru",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 24),

                          CustomInputField(
                            controller: _usernameController,
                            labelText: 'Username',
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Masukkan username' : null,
                          ),
                          const SizedBox(height: 16),

                          CustomInputField(
                            controller: _emailController,
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                value == null || !GetUtils.isEmail(value) ? 'Email tidak valid' : null,
                          ),
                          const SizedBox(height: 16),

                          CustomInputField(
                            controller: _passwordController,
                            labelText: 'Password',
                            obscureText: true,
                            validator: (value) =>
                                value == null || value.length < 6 ? 'Password minimal 6 karakter' : null,
                          ),
                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: InputDecoration(
                              labelText: 'Jenis Kelamin',
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(23),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(23),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(23),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                            ),
                            items: const [
                              
                              DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                              DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                            ],
                            validator: (value) => value == null ? 'Pilih jenis kelamin' : null,
                            onChanged: (value) => setState(() => _gender = value),
                          ),
                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: () => _selectBirthdate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Tanggal Lahir',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(23),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(23),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(23),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                              ),
                              child: Text(
                                _birthdate == null
                                    ? 'Pilih Tanggal Lahir'
                                    : '${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _birthdate == null ? Colors.grey : Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          _isLoading
                              ? const CircularProgressIndicator()
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                   
                                    label: const Text('Daftar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(207, 255, 0, 0),
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(23),
                                      ),
                                    ),
                                    onPressed: _signUp,
                                  ),
                                ),
                        ],
                      ),
                    ),
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
