import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../component/top_bar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF1EAE3),
    appBar: const CustomTopBar(activePage: 'Notifications'),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifikasi',
            style: GoogleFonts.inter(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pembaruan terkait buku dan pesanan Anda.',
            style: GoogleFonts.inter(color: Colors.black54),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Belum ada notifikasi. Notifikasi akan muncul saat fitur ini terhubung ke layanan pemberitahuan.',
              style: GoogleFonts.inter(color: Colors.black54),
            ),
          ),
        ],
      ),
    ),
  );
}
