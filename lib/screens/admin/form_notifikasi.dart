import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';
import 'list_notifikasi.dart';

class FormNotifikasi extends StatefulWidget {
  const FormNotifikasi({super.key});

  @override
  State<FormNotifikasi> createState() => _FormNotifikasiState();
}

class _FormNotifikasiState extends State<FormNotifikasi> {
  final _judulController = TextEditingController();
  final _pesanController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _status = '';
  int? _selectedBeritaId;
  String? _imageUrl;

  List<Map<String, dynamic>> _beritaList = [];

  final String sistemImageUrl =
      'https://yveiqftpcacwvnqbxrco.supabase.co/storage/v1/object/public/berita-images/f31604ab-5389-4a01-bab8-041da6d8ac55/1751443638286.jpg';

  @override
  void initState() {
    super.initState();
    _fetchBerita();
  }

  Future<void> _fetchBerita() async {
    try {
      final response = await Supabase.instance.client
          .from('berita')
          .select('id, title, content, image_url');
      setState(() {
        _beritaList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      log('Gagal mengambil berita: $e');
    }
  }

  Future<void> _kirimNotifikasi() async {
    if (_formKey.currentState!.validate()) {
      if (_status == 'berita' && _selectedBeritaId == null) {
        Get.snackbar('Error', 'Silakan pilih berita',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      setState(() => _isLoading = true);

      if (_status == 'sistem') {
        _imageUrl = sistemImageUrl;
      }

      final data = {
        'judul': _judulController.text.trim(),
        'pesan': _pesanController.text.trim(),
        'status': _status,
        'berita_id': _status == 'berita' ? _selectedBeritaId : null,
        'image_url': _imageUrl,
        'user_id': Supabase.instance.client.auth.currentUser?.id,
      };

      try {
        await Supabase.instance.client.from('notifikasi').insert(data);
        Get.snackbar('Sukses', 'Notifikasi berhasil dikirim',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.off(() => const ListNotifikasi());
      } catch (e) {
        Get.snackbar('Error', 'Gagal mengirim notifikasi: $e',
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Notifikasi'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _status.isEmpty ? null : _status,
                decoration: const InputDecoration(
                  labelText: 'Jenis Notifikasi',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'sistem', child: Text('Sistem')),
                  DropdownMenuItem(value: 'berita', child: Text('Berita')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                    _judulController.clear();
                    _pesanController.clear();
                    _selectedBeritaId = null;
                    _imageUrl = null;
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Pilih jenis notifikasi' : null,
              ),
              const SizedBox(height: 16),
              if (_status == 'sistem') ...[
                TextFormField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pesanController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Isi Notifikasi',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Isi wajib diisi' : null,
                ),
              ],
              if (_status == 'berita')
                _beritaList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<int>(
                        value: _selectedBeritaId,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Berita',
                          border: OutlineInputBorder(),
                        ),
                        items: _beritaList
                            .map((berita) => DropdownMenuItem<int>(
                                  value: berita['id'],
                                  child: Text(berita['title'] ?? 'Tanpa Judul'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          final selected = _beritaList.firstWhere(
                              (b) => b['id'] == value,
                              orElse: () => {});
                          setState(() {
                            _selectedBeritaId = value;
                            _judulController.text = selected['title'] ?? '';
                            _pesanController.text = selected['content'] ?? '';
                            _imageUrl = selected['image_url'] ?? '';
                          });
                        },
                      ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _kirimNotifikasi,
                  icon: const Icon(Icons.send),
                  label: _isLoading
                      ? const Text('Mengirim...')
                      : const Text('Kirim Notifikasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
