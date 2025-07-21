import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_routes.dart';

class AdminSidebar extends StatelessWidget {
  final String? selectedRoute;

  const AdminSidebar({super.key, this.selectedRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blueGrey.shade900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: const [
                  Icon(Icons.newspaper, color: Colors.white, size: 50),
                  SizedBox(height: 8),
                  Text(
                    'Breaking News',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white54),

            // Menu: Pengguna
            _buildMenuItem(
              icon: Icons.people,
              title: 'Pengguna',
              routeName: AppRoutes.penggunaAdmin,
            ),

            // Menu: Berita
            _buildMenuItem(
              icon: Icons.article,
              title: 'Berita',
              routeName: AppRoutes.beritaList,
            ),

            // Menu: Notifikasi
            _buildMenuItem(
              icon: Icons.notifications,
              title: 'Notifikasi',
              routeName: AppRoutes.listNotifikasi,
            ),

            // Menu: Data Disimpan
            _buildMenuItem(
              icon: Icons.bookmark,
              title: 'Data Disimpan',
              routeName: AppRoutes.beritaDisimpanAdmin,
            ),

            const Spacer(),

            // Menu: Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String routeName,
  }) {
    final isSelected = selectedRoute == routeName;

    return Container(
      color: isSelected ? Colors.blueGrey.shade700 : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: () => Get.toNamed(routeName),
      ),
    );
  }
}
