// lib/screens/user/detail_berita_screen.dart
import 'package:flutter/material.dart';
import '../../../models/berita_model.dart';

class DetailBeritaScreen extends StatelessWidget {
  final Berita berita;

  const DetailBeritaScreen({super.key, required this.berita});

  String getCategoryName(int? id) {
    switch (id) {
      case 1:
        return 'Olahraga';
      case 2:
        return 'Hiburan';
      case 3:
        return 'Politik';
      default:
        return 'Lainnya';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(berita.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (berita.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  berita.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              getCategoryName(berita.categoryId),
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              berita.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              berita.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
