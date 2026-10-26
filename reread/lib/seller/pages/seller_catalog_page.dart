import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../component/top_bar.dart'; // Pastikan path ini mengarah ke file header yang kita buat sebelumnya

class SellerCatalogPage extends StatelessWidget {
  const SellerCatalogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EAE3), // Warna latar belakang abu-abu kecoklatan
      appBar: const CustomTopBar(), // Ingat untuk mengatur status aktif menu navigasi jika Anda membuatnya dinamis
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle
            Text(
              'My Catalog',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Trusted seller - 4.9 rating - 126 books rehomed',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF7A7A7A),
              ),
            ),
            const SizedBox(height: 24),

            // Full Width Search Bar
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF888888), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by title, author, or ISBN',
                        hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF888888)),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Header Section: Count & Sort
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '248 books available',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF888888)),
                ),
                Row(
                  children: [
                    Text(
                      'Sort: Recommended',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_downward, size: 16, color: Color(0xFF2C2C2C)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Books Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Agar scroll mengikuti SingleChildScrollView utama
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // 5 kolom sesuai desain
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.62, // Rasio tinggi-lebar kartu, sesuaikan jika teks kepanjangan
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                // Data dummy untuk dirender sesuai urutan gambar
                final List<Map<String, String>> books = [
                  {'title': 'The Midnight Library', 'author': 'Matt Haig', 'price': '\$9.50', 'condition': ''},
                  {'title': 'Before the Coffee Gets Cold', 'author': 'Toshikazu Kawaguchi', 'price': '\$8.00', 'condition': 'Very good'},
                  {'title': 'The Vanishing Half', 'author': 'Brit Bennett', 'price': '\$11.25', 'condition': 'Very good'},
                  {'title': 'Klara and the Sun', 'author': 'Kazuo Ishiguro', 'price': '\$10.00', 'condition': 'Very good'},
                  {'title': 'Circe', 'author': 'Madeline Miller', 'price': '\$7.75', 'condition': 'Very good'},
                ];
                
                final book = books[index % 5];
                
                return _buildSellerBookCard(
                  title: book['title']!,
                  author: book['author']!,
                  price: book['price']!,
                  condition: book['condition']!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerBookCard({
    required String title,
    required String author,
    required String price,
    required String condition,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover Placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBEB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.menu_book, size: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Author
          Text(
            author,
            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF888888)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Price & Condition
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
              ),
              if (condition.isNotEmpty)
                Text(
                  condition,
                  style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF00A650), fontWeight: FontWeight.w500),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Edit Button
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5500),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {},
              child: Text(
                'edit',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}