import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_sidebar.dart';

class PenggunaAdmin extends StatefulWidget {
  const PenggunaAdmin({super.key});

  @override
  State<PenggunaAdmin> createState() => _PenggunaAdminState();
}

class _PenggunaAdminState extends State<PenggunaAdmin> {
  final SupabaseClient _client = Supabase.instance.client;
  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    setState(() => _isLoading = true);
    try {
      final response = await _client
          .from('profiles')
          .select()
          .order('updated_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _profiles = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data pengguna: $e'),
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
                          '📋 Data Pengguna',
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
                                DataColumn(label: Text('User ID')),
                                DataColumn(label: Text('Username')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Gender')),
                                DataColumn(label: Text('Birthdate')),
                                DataColumn(label: Text('Avatar URL')),
                                DataColumn(label: Text('Terakhir Diperbarui')),
                              ],
                              rows: _profiles.map((profile) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(profile['id'] ?? '-')),
                                    DataCell(Text(profile['username'] ?? '-')),
                                    DataCell(Text(profile['email'] ?? '-')),
                                    DataCell(Text(profile['gender'] ?? '-')),
                                    DataCell(Text(profile['birthdate'] ?? '-')),
                                    DataCell(
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          profile['avatar_url'] ?? '-',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(
                                        profile['updated_at']?.toString() ?? '-')),
                                  ],
                                );
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
