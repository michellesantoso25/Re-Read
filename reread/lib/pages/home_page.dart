import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/navbar.dart';
import '../main.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: const CustomNavbar(),
      body: Container(
        color: const Color(0xFFECE6DF),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang di Re:Read!',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22201F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Login sebagai: ${user?.email ?? "Guest"}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE05627),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _signOut(context),
                icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                label: Text(
                  'Sign Out',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}