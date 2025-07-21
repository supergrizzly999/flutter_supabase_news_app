import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/berita_model.dart';
import '../home/detail_berita_screen.dart';
import 'detail_notifikasi.dart';
import 'menu.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifikasiList = [];
  bool _isLoading = true;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _fetchNotifikasi();
  }

  Future<void> _fetchNotifikasi() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Anda belum login');
      return;
    }

    try {
      final profileData = await supabase
          .from('profiles')
          .select('created_at')
          .eq('id', user.id)
          .single();

      final userCreatedAt = DateTime.parse(profileData['created_at']);

      final notifList = await supabase
          .from('notifikasi')
          .select()
          .gt('created_at', userCreatedAt.toIso8601String())
          .order('created_at', ascending: false);

      setState(() {
        _notifikasiList = List<Map<String, dynamic>>.from(notifList);
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat notifikasi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onBottomMenuTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Get.offAllNamed('/home');
    } else if (index == 1) {
      Get.offAllNamed('/simpan-berita');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.notifications_none, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Notifikasi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://yveiqftpcacwvnqbxrco.supabase.co/storage/v1/object/public/berita-images/f31604ab-5389-4a01-bab8-041da6d8ac55/1750688220230.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay
          Container(color: Colors.black.withAlpha(102)),

          // Content
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifikasiList.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada notifikasi.',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _notifikasiList.length,
                        itemBuilder: (context, index) {
                          final notif = _notifikasiList[index];
                          final tanggal = notif['created_at']
                                  ?.toString()
                                  .split('T')
                                  .first ??
                              '';
                          final status = notif['status'] ?? 'sistem';
                          final beritaId = notif['berita_id'];
                          final judul = notif['judul'] ?? 'Tanpa judul';
                          final imageUrl = notif['image_url'];

                          return InkWell(
                            onTap: () async {
                              if (status == 'berita' && beritaId != null) {
                                try {
                                  final data = await supabase
                                      .from('berita')
                                      .select()
                                      .eq('id', beritaId)
                                      .single();

                                  final berita = Berita.fromJson(data);
                                  Get.to(() => DetailBeritaScreen(berita: berita));
                                } catch (e) {
                                  Get.snackbar(
                                    'Error',
                                    'Gagal mengambil detail berita: $e',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              } else {
                                Get.to(() => DetailNotifikasi(
                                      judul: judul,
                                      pesan: notif['pesan'] ?? '',
                                      tanggal: tanggal,
                                      pengirim: 'Admin',
                                    ));
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(240),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(30),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color.fromARGB(255, 250, 59, 59), width: 2),
                                      image: DecorationImage(
                                        image: imageUrl != null
                                            ? NetworkImage(imageUrl)
                                            : const AssetImage('assets/no-image.png') as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          judul,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notif['pesan'] ?? '',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[800],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tanggal,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
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
      bottomNavigationBar: BottomMenu(
        selectedIndex: _selectedIndex,
        onTap: _onBottomMenuTap,
      ),
    );
  }
}
