import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart'; // akses supabase client global

class SupabaseService {
  final String bucketName = 'berita-images';

  // Upload image dari File (mobile)
  Future<String> uploadImage(File file, String fileName) async {
    final bytes = await file.readAsBytes();
    await supabase.storage.from(bucketName).uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  // Upload image dari Bytes (web)
  Future<String> uploadImageBytes(Uint8List bytes, String fileName) async {
    await supabase.storage.from(bucketName).uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  // Ambil berita milik user saat ini (tanpa kategori)
  Future<List<Map<String, dynamic>>> getBerita() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('berita')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return data;
  }

  // Ambil semua berita dengan relasi kategori (untuk admin)
  Future<List<Map<String, dynamic>>> getBeritaWithKategori() async {
    final data = await supabase
        .from('berita')
        .select('*, kategori(nama)')
        .order('created_at', ascending: false);
    return data;
  }

  // Tambah berita
  Future<void> addBerita({
    required String title,
    required String content,
    String? imageUrl,
    required int categoryId,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('berita').insert({
      'user_id': userId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'category_id': categoryId,
    });
  }

  // Update berita
  Future<void> updateBerita({
    required int id,
    required String title,
    required String content,
    String? imageUrl,
    required int categoryId,
  }) async {
    final updates = {
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'category_id': categoryId,
    };
    await supabase.from('berita').update(updates).eq('id', id);
  }

  // Hapus berita
  Future<void> deleteBerita(int id) async {
    await supabase.from('berita').delete().eq('id', id);
  }

  // Ambil profile
  Future<Map<String, dynamic>?> getProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      final defaultProfile = {
        'id': userId,
        'username': supabase.auth.currentUser!.email?.split('@')[0],
        'avatar_url': null,
      };
      await supabase.from('profiles').insert(defaultProfile);
      return defaultProfile;
    }

    return response;
  }

  // Update profile
  Future<void> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final updates = {
      'id': userId,
      'username': username,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (avatarUrl != null) {
      updates['avatar_url'] = avatarUrl;
    }
    await supabase.from('profiles').upsert(updates);
  }
}
