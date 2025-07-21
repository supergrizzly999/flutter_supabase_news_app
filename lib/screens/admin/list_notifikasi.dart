import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/notifikasi_model.dart';
import 'form_notifikasi.dart';
import 'admin_sidebar.dart';
import '../../utils/app_routes.dart';

class ListNotifikasi extends StatefulWidget {
  const ListNotifikasi({super.key});

  @override
  State<ListNotifikasi> createState() => _ListNotifikasiState();
}

class _ListNotifikasiState extends State<ListNotifikasi> {
  final supabase = Supabase.instance.client;
  late Future<List<NotifikasiModel>> _notifikasiFuture;

  Future<List<NotifikasiModel>> _fetchNotifikasi() async {
    final response = await supabase
        .from('notifikasi')
        .select('''
          id, judul, pesan, created_at, user_id, image_url,
          profiles!fk_user_id(username)
        ''')
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => NotifikasiModel.fromMap(data))
        .toList();
  }

  Future<void> _hapusNotifikasi(String id) async {
    try {
      await supabase.from('notifikasi').delete().eq('id', id);
      setState(() {
        _notifikasiFuture = _fetchNotifikasi();
      });
      Get.snackbar('Sukses', 'Notifikasi berhasil dihapus',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus notifikasi',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void initState() {
    super.initState();
    _notifikasiFuture = _fetchNotifikasi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(selectedRoute: AppRoutes.listNotifikasi),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  color: Colors.white,
                  width: double.infinity,
                  child: const Text(
                    'Daftar Notifikasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<NotifikasiModel>>(
                    future: _notifikasiFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text('Gagal memuat data: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Belum ada notifikasi.'));
                      }

                      final notifikasiList = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifikasiList.length,
                        itemBuilder: (context, index) {
                          final notif = notifikasiList[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  notif.imageUrl != null &&
                                          notif.imageUrl!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            notif.imageUrl!,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, _) =>
                                                    const Icon(Icons
                                                        .image_not_supported),
                                          ),
                                        )
                                      : const Icon(Icons.notifications,
                                          size: 40, color: Colors.grey),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notif.judul ?? '(Tanpa Judul)',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notif.pesan ?? '(Tanpa Pesan)',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Dikirim oleh: ${notif.username ?? "Tidak diketahui"}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${notif.createdAt.day}/${notif.createdAt.month}/${notif.createdAt.year}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _hapusNotifikasi(notif.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
        onPressed: () => Get.to(() => const FormNotifikasi()),
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
