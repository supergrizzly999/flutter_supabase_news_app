import 'package:get/get.dart';

// Auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

// Home & User
import '../screens/home/home_screen.dart';
import '../screens/home/simpan_berita_screen.dart';
import '../screens/home/notifikasi_screen.dart';


// Admin
import '../screens/admin/berita_form.dart';
import '../screens/admin/berita_list.dart';
import '../screens/admin/pengguna_admin.dart';
import '../screens/admin/berita_disimpan_admin.dart';
import '../screens/admin/form_notifikasi.dart'; // ✅ perbaikan path
import '../screens/admin/list_notifikasi.dart'; // ✅ jika ingin pakai halaman list

// Splash
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  
  static const String home = '/home';
  static const String beritaForm = '/berita-form';
  static const String simpanBerita = '/simpan-berita';
  static const String beritaList = '/berita';
  static const String penggunaAdmin = '/admin/pengguna';
  static const String beritaDisimpanAdmin = '/admin/berita-disimpan';
  static const String notifikasi = '/notifikasi';
  static const String notifikasiAdmin = '/admin/notifikasi';
  static const String listNotifikasi = '/admin/list-notifikasi'; // ✅ jika ingin halaman list

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: beritaForm, page: () => const BeritaFormScreen()),
    GetPage(name: simpanBerita, page: () => const SimpanBeritaScreen()),
    GetPage(name: beritaList, page: () => const BeritaListScreen()),
    GetPage(name: penggunaAdmin, page: () => const PenggunaAdmin()),
    GetPage(name: beritaDisimpanAdmin, page: () => const BeritaDisimpanAdmin()),
    GetPage(name: notifikasi, page: () => const NotifikasiScreen()),
    GetPage(name: notifikasiAdmin, page: () => const FormNotifikasi()), // ✅ benar
    GetPage(name: listNotifikasi, page: () => const ListNotifikasi()),   // ✅ opsional
  ];
}
