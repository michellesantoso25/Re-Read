import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Format angka ke Rupiah, contoh: 85000 -> "Rp 85.000"
String formatRupiah(dynamic price) {
  final value = (price ?? 0) as int;
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return 'Rp $buffer';
}

/// Kartu buku yang dipakai di HomePage dan GenrePage.
/// Ukurannya mengikuti parent (mis. GridView dengan mainAxisExtent 330).
class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cover = book['cover'] as String?;
    final stock = (book['stock'] ?? 0) as int;
    final condition = (book['condition'] ?? 'Good') as String;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 170,
              width: double.infinity,
              child: _buildCover(cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book['title'] ?? '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(
            book['author'] ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 9, color: Colors.grey),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatRupiah(book['price']),
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Text(
                condition,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _conditionColor(condition),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            stock > 0 ? 'Stock: $stock' : 'Sold out',
            style: GoogleFonts.inter(
              fontSize: 9,
              color: stock > 0 ? Colors.black54 : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 28,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE05627),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: stock > 0 ? () {} : null,
              child: Text(
                'ADD TO CART',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cover bisa berupa URL (http...) atau path aset (lib/assets/covers/...)
  Widget _buildCover(String? cover) {
    if (cover == null || cover.isEmpty) return _placeholder();
    if (cover.startsWith('http')) {
      return Image.network(
        cover,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return Image.asset(
      cover,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Color _conditionColor(String condition) {
    switch (condition) {
      case 'Like new':
        return const Color(0xFF1B8A5A);
      case 'Very good':
        return const Color(0xFF3C8D40);
      default:
        return const Color(0xFFB8860B);
    }
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.book, size: 40, color: Colors.white)),
    );
  }
}