// lib/screens/user/simpan_berita_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/berita_model.dart';
import 'menu.dart';
import 'user_sidebar.dart';
import 'detail_berita_screen.dart';

class SimpanBeritaScreen extends StatefulWidget {
  const SimpanBeritaScreen({super.key});

  @override
  State<SimpanBeritaScreen> createState() => _SimpanBeritaScreenState();
}

class _SimpanBeritaScreenState extends State<SimpanBeritaScreen> {
  List<Berita> _savedBerita = [];
  List<Berita> _allSavedBerita = [];
  List<int> _savedBeritaIds = [];
  bool _isLoading = true;
  int _selectedIndex = 1;

  String? _avatarUrl;
  String? _username;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSavedBerita();
    _loadUserProfile();
  }

  Future<void> _fetchSavedBerita() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        Get.snackbar('Error', 'Anda belum login');
      }
      return;
    }

    if (mounted) setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('berita_disimpan')
          .select('berita_id, berita (id, user_id, title, content, image_url, category_id, created_at)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final beritaList = (data as List)
          .map((item) => Berita.fromJson(item['berita']))
          .toList();

      _savedBeritaIds = beritaList.map((b) => b.id).toList();

      if (!mounted) return;
      setState(() {
        _allSavedBerita = beritaList;
        _savedBerita = beritaList;
      });
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Gagal memuat berita: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    if (!mounted) return;
    setState(() {
      _username = response['username'] ?? 'Pengguna';
      _avatarUrl = response['avatar_url'];
    });
  }

  void _onSearchChanged(String query) {
    final keyword = query.toLowerCase();
    setState(() {
      _savedBerita = _allSavedBerita
          .where((berita) => berita.title.toLowerCase().contains(keyword))
          .toList();
    });
  }

  Future<void> _unsaveBerita(Berita berita) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client
          .from('berita_disimpan')
          .delete()
          .eq('user_id', user.id)
          .eq('berita_id', berita.id);

      if (!mounted) return;
      setState(() {
        _savedBerita.removeWhere((b) => b.id == berita.id);
        _allSavedBerita.removeWhere((b) => b.id == berita.id);
        _savedBeritaIds.remove(berita.id);
      });

      if (mounted) {
        Get.snackbar('Berhasil', 'Berita dibatalkan dari simpanan');
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Gagal batal simpan: $e');
      }
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Cari berita berdasarkan judul...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withAlpha(229),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBeritaCard(Berita berita, int index) {
    return GestureDetector(
      onTap: () {
        Get.to(() => DetailBeritaScreen(berita: berita));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(242),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(38),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: berita.imageUrl != null
                  ? Image.network(
                      berita.imageUrl!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 40),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    berita.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Breaking News',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark, color: Colors.blue),
              onPressed: () => _unsaveBerita(berita),
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomMenuTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserSidebar(
        isLoading: _isLoading,
        avatarUrl: _avatarUrl,
        username: _username,
        onProfileUpdated: _loadUserProfile,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Berita Disimpan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              height: 50,
              width: 100,
              child: Image.network(
                'https://yveiqftpcacwvnqbxrco.supabase.co/storage/v1/object/public/berita-images/f31604ab-5389-4a01-bab8-041da6d8ac55/1750476285018.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://yveiqftpcacwvnqbxrco.supabase.co/storage/v1/object/public/berita-images/f31604ab-5389-4a01-bab8-041da6d8ac55/1750688220230.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withAlpha(102)),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildSearchBar(),
                      Expanded(
                        child: _savedBerita.isEmpty
                            ? const Center(
                                child: Text(
                                  'Belum ada berita yang disimpan.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _savedBerita.length,
                                itemBuilder: (context, index) {
                                  return _buildBeritaCard(_savedBerita[index], index);
                                },
                              ),
                      ),
                    ],
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
