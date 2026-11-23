import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../component/top_bar.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF1EAE3),
    appBar: const CustomTopBar(activePage: ''),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pesan',
            style: GoogleFonts.inter(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Percakapan dengan pembeli.',
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
              'Belum ada percakapan. Fitur pesan belum terhubung ke layanan chat.',
              style: GoogleFonts.inter(color: Colors.black54),
            ),
          ),
        ],
      ),
    ),
  );
}
