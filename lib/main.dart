import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/landing.dart';
import './notifiers.dart';

void main() {
  runApp(const MyApp()); //menampilkan widget root (utama)
}

class MyApp extends StatelessWidget { // kelas MyApp merupakan turunan dari StatelessWidget, mewarisi sifat dari statelessWidget
  const MyApp({super.key}); //super.key digunakan untuk membedakan widget di widget tree (jika widget beranimasi, harus diinisiasi manual, defaultnya null)
  @override // method untuk menggantikan fungsi build bawaan dari statelessWidget/statefulWidget (defaultnya memang kosong)
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedThemeNotifier,
      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'List Anggota',
          themeMode: value ? ThemeMode.dark : ThemeMode.light,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: const AuthCheckPage(),
        );
      },
    );
  }
}

class AuthCheckPage extends StatefulWidget { // StatefulWidget hanya menjadi kerangka saja, kelas pada createState() yang akan mengelola tampilan dan logika
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState(); // jika build kelas authCheckPage(), gunakan kelas _AuthCheckPageState untuk mengatur tampilan dan logika
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  final AuthService _authService = AuthService(); // variable _authService bertipedata AuthService, dengan nilai masukan konstruktor AuthService(), untuk bisa menggunakan fitur yang ada di dalam authService disini

  @override
  void initState() {
    super.initState(); // menjalankan initstate() dari parent state (initstate atau perispan standar flutter)
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();

    if (!mounted) return; // semisal ketika _checkLoginStatus() dijalankan, kita menekan tombol home, maka widget ini dihapus dari widget tree

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? const LandingPage() : const LoginPage(),
      ),
      (route) => false, // jika true maka semua route tidak ada yang dihapus
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // kerangka dasar membuat tampilan halaman aplikasi, jika ingin menggunakan yang lain maka bisa menggunakan parameter body di daalam Scaffold saja
      body: Center(
        child: const CircularProgressIndicator()
      ),
    );
  }
}