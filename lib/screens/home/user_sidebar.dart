import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/app_routes.dart';
import 'profile_bottom_sheet.dart'; // ✅ Import bottom sheet edit profil

class UserSidebar extends StatelessWidget {
  final bool isLoading;
  final String? avatarUrl;
  final String? username;
  final VoidCallback onProfileUpdated;

  const UserSidebar({
    super.key,
    required this.isLoading,
    required this.avatarUrl,
    required this.username,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E2A38), Color(0xFF2C3E50)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Profil
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : CircleAvatar(
                              radius: 40,
                              backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                                  ? NetworkImage(avatarUrl!)
                                  : const NetworkImage('https://via.placeholder.com/150'),
                              backgroundColor: Colors.white,
                              child: (avatarUrl == null || avatarUrl!.isEmpty)
                                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                  : null,
                            ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Good Morning',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              username ?? 'Pengguna',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tombol Edit Profil
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: TextButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return DraggableScrollableSheet(
                            expand: false,
                            initialChildSize: 0.6, // ✅ Lebih pendek
                            minChildSize: 0.5,
                            maxChildSize: 0.9,
                            builder: (_, controller) => ProfileBottomSheet(
                              onProfileUpdated: onProfileUpdated,
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                    label: const Text(
                      'Edit Profil',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const Divider(color: Colors.white24, thickness: 1, indent: 16, endIndent: 16),
                const Spacer(),

                // Tombol Logout
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    Get.offAllNamed(AppRoutes.splash);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
