import 'package:flutter/material.dart';

class DetailNotifikasi extends StatelessWidget {
  final String judul;
  final String pesan;
  final String tanggal;
  final String pengirim;

  const DetailNotifikasi({
    super.key,
    required this.judul,
    required this.pesan,
    required this.tanggal,
    required this.pengirim,
  });

  @override
  Widget build(BuildContext context) {
    const String imageUrl =
        'https://yveiqftpcacwvnqbxrco.supabase.co/storage/v1/object/public/berita-images/f31604ab-5389-4a01-bab8-041da6d8ac55/1751443638286.jpg';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://yveiqftpcacwvnqbxrco.supabase.co/storage/v1/object/public/berita-images/f31604ab-5389-4a01-bab8-041da6d8ac55/1750688220230.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay gelap
          Container(color: Colors.black.withAlpha(102)),

          // Konten utama
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar dan Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(imageUrl),
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              judul,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16, color: Color.fromARGB(255, 255, 255, 255)),
                                const SizedBox(width: 6),
                                Text(
                                  "Dikirim oleh: $pengirim",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Color.fromARGB(255, 255, 255, 255)),
                                const SizedBox(width: 6),
                                Text(
                                  "Tanggal: $tanggal",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1, color: Color.fromARGB(255, 255, 255, 255),),
                  const SizedBox(height: 16),
                  Text(
                    pesan,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
