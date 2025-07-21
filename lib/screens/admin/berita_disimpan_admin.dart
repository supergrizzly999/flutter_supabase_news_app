import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_sidebar.dart';

class BeritaDisimpanAdmin extends StatefulWidget {
  const BeritaDisimpanAdmin({super.key});

  @override
  State<BeritaDisimpanAdmin> createState() => _BeritaDisimpanAdminState();
}

class _BeritaDisimpanAdminState extends State<BeritaDisimpanAdmin> {
  final SupabaseClient _client = Supabase.instance.client;
  List<Map<String, dynamic>> _savedList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSavedBerita();
  }

  Future<void> _fetchSavedBerita() async {
    setState(() => _isLoading = true);
    try {
      final data = await _client
          .from('berita_disimpan')
          .select('created_at, profiles (username, email), berita (title, id)')
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _savedList = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat berita disimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🔖 Berita Disimpan Pengguna',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                Colors.blueGrey.shade50,
                              ),
                              columnSpacing: 24,
                              columns: const [
                                DataColumn(label: Text('Judul Berita')),
                                DataColumn(label: Text('Username')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Waktu Disimpan')),
                              ],
                              rows: _savedList.map((item) {
                                final berita = item['berita'];
                                final user = item['profiles'];
                                return DataRow(cells: [
                                  DataCell(Text(berita?['title'] ?? '-')),
                                  DataCell(Text(user?['username'] ?? '-')),
                                  DataCell(Text(user?['email'] ?? '-')),
                                  DataCell(Text(item['created_at'] ?? '-')),
                                ]);
                              }).toList(),
                            ),
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
