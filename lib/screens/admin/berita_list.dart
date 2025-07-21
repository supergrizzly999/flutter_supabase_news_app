import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/berita_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../admin/admin_sidebar.dart';

class BeritaListScreen extends StatefulWidget {
  const BeritaListScreen({super.key});

  @override
  State<BeritaListScreen> createState() => _BeritaListScreenState();
}

class _BeritaListScreenState extends State<BeritaListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Berita> _beritaList = [];
  Map<int, String> _kategoriMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBerita();
  }

  Future<void> _fetchBerita() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getBeritaWithKategori();

      _beritaList = data.map((item) => Berita.fromJson(item)).toList();

      _kategoriMap = {
        for (var item in data)
          if (item['category_id'] != null && item['kategori'] != null)
            item['category_id']: item['kategori']['nama'] as String
      };

      setState(() {});
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat berita: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBerita(int id) async {
    try {
      await _supabaseService.deleteBerita(id);
      Get.snackbar(
        'Sukses',
        'Berita berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _fetchBerita();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus berita: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showDeleteConfirmation(int id) {
    Get.defaultDialog(
      title: "Hapus Berita",
      middleText: "Apakah Anda yakin ingin menghapus berita ini?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        _deleteBerita(id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.list_alt, size: 28, color: Colors.black),
                      SizedBox(width: 12),
                      Text(
                        'Daftar Berita',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _beritaList.isEmpty
                          ? const Center(child: Text('Belum ada berita yang ditambahkan.'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _beritaList.length,
                              itemBuilder: (context, index) {
                                final berita = _beritaList[index];
                                final kategori =
                                    _kategoriMap[berita.categoryId] ?? 'Tanpa Kategori';

                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: berita.imageUrl != null
                                        ? Image.network(
                                            berita.imageUrl!,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.article, size: 40),
                                    title: Text(
                                      berita.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          kategori,
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          berita.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () async {
                                            final result = await Get.toNamed(
                                              AppRoutes.beritaForm,
                                              arguments: berita,
                                            );
                                            if (result == true) {
                                              _fetchBerita();
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _showDeleteConfirmation(berita.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed(AppRoutes.beritaForm);
          if (result == true) {
            _fetchBerita();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
