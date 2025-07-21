import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/berita_model.dart';
import 'user_sidebar.dart';
import 'menu.dart';
import 'simpan_berita_screen.dart';
import 'detail_berita_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Berita> _beritaList = [];
  List<Berita> _allBeritaList = [];
  List<int> _savedBeritaIds = [];
  bool _isLoading = true;

  String? _avatarUrl;
  String? _username;
  int _selectedIndex = 0;

  final String targetUserId = 'f31604ab-5389-4a01-bab8-041da6d8ac55';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _kategori = ['Semua', 'Olahraga', 'Hiburan', 'Politik'];
  String _selectedKategori = 'Semua';

  @override
  void initState() {
    super.initState();
    _fetchBerita();
    _loadUserProfile();
    _fetchSavedBerita();
  }

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

  Future<void> _fetchBerita() async {
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('berita')
          .select()
          .eq('user_id', targetUserId)
          .order('created_at', ascending: false);

      _allBeritaList = (data as List).map((item) => Berita.fromJson(item)).toList();

      if (!mounted) return;
      setState(() {
        _beritaList = _allBeritaList;
      });
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Gagal memuat berita: $e',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchSavedBerita() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('berita_disimpan')
          .select('berita_id')
          .eq('user_id', user.id);

      final ids = (response as List).map((item) => item['berita_id'] as int).toList();

      if (!mounted) return;
      setState(() {
        _savedBeritaIds = ids;
      });
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Gagal mengambil data berita yang disimpan: $e');
      }
    }
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id;

    if (userId != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      if (!mounted) return;
      setState(() {
        _username = response['username'] ?? 'Pengguna';
        _avatarUrl = response['avatar_url'];
      });
    }
  }

  Future<void> _toggleSaveBerita(Berita berita) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        Get.snackbar('Error', 'Anda belum login');
      }
      return;
    }

    final isSaved = _savedBeritaIds.contains(berita.id);

    try {
      if (isSaved) {
        await Supabase.instance.client
            .from('berita_disimpan')
            .delete()
            .eq('user_id', user.id)
            .eq('berita_id', berita.id);
        if (mounted) {
          Get.snackbar('Berhasil', 'Berita dihapus dari simpanan');
        }
      } else {
        await Supabase.instance.client.from('berita_disimpan').insert({
          'user_id': user.id,
          'berita_id': berita.id,
          'created_at': DateTime.now().toIso8601String(),
        });
        if (mounted) {
          Get.snackbar('Berhasil', 'Berita berhasil disimpan');
        }
      }
      await _fetchSavedBerita();
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Terjadi kesalahan: $e');
      }
    }
  }

  void _onBottomMenuTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Get.to(() => const SimpanBeritaScreen());
    }
  }

  void _onCardTap(Berita berita) {
    Get.to(() => DetailBeritaScreen(berita: berita));
  }

  void _onSearchChanged(String query) {
    final keyword = query.toLowerCase();
    setState(() {
      _beritaList = _allBeritaList
          .where((berita) => berita.title.toLowerCase().contains(keyword))
          .toList();
    });
  }

  void _filterByKategori(String kategori) {
    setState(() {
      _selectedKategori = kategori;
      if (kategori == 'Semua') {
        _beritaList = _allBeritaList;
      } else {
        _beritaList = _allBeritaList.where((berita) {
          final namaKategori = getCategoryName(berita.categoryId).toLowerCase();
          return namaKategori == kategori.toLowerCase();
        }).toList();
      }
    });
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
          fillColor: const Color.fromRGBO(255, 255, 255, 0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildKategoriMenu() {
    Map<String, IconData> kategoriIcons = {
      'Semua': Icons.grid_view_rounded,
      'Olahraga': Icons.sports_soccer,
      'Hiburan': Icons.movie_filter,
      'Politik': Icons.gavel,
    };

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _kategori.length,
        itemBuilder: (context, index) {
          final kategori = _kategori[index];
          final isSelected = _selectedKategori == kategori;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFF32121), Color(0xFFFFA640)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: InkWell(
              onTap: () => _filterByKategori(kategori),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    kategoriIcons[kategori],
                    color: isSelected ? Colors.white : Colors.grey[700],
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    kategori,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBeritaCard(Berita berita, int index) {
    final bool isSaved = _savedBeritaIds.contains(berita.id);

    return GestureDetector(
      onTap: () => _onCardTap(berita),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
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
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    getCategoryName(berita.categoryId),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? Colors.blue : Colors.grey[600],
              ),
              onPressed: () => _toggleSaveBerita(berita),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Beranda',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://yveiqftpcacwvnqbxrco.supabase.co/storage/v1/object/public/berita-images/f31604ab-5389-4a01-bab8-041da6d8ac55/1750603232311.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: const Color.fromRGBO(0, 0, 0, 0.4),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildSearchBar(),
                      _buildKategoriMenu(),
                      Expanded(
                        child: _beritaList.isEmpty
                            ? const Center(child: Text('Berita tidak ditemukan.', style: TextStyle(color: Colors.white)))
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: _beritaList.length,
                                itemBuilder: (context, index) {
                                  final berita = _beritaList[index];
                                  return _buildBeritaCard(berita, index);
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
