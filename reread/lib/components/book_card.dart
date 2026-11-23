import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reread/components/book_description_page.dart';
import 'package:reread/components/cart_feedback.dart';

/// Format angka ke Rupiah, contoh: 85000 -> "Rp 85.000"
String formatRupiah(dynamic price) {
  final value = (price ?? 0) is int
      ? price as int
      : (price as num?)?.toInt() ?? 0;
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return 'Rp $buffer';
}

/// Warna label kondisi buku (dipakai di BookCard dan BookDescriptionPage).
Color conditionColor(String condition) {
  switch (condition) {
    case 'Like new':
      return const Color(0xFF1B8A5A);
    case 'Very good':
      return const Color(0xFF3C8D40);
    default:
      return const Color(0xFFB8860B);
  }
}

/// Kartu buku yang dipakai di HomePage dan GenrePage.
/// Ukurannya mengikuti parent (mis. GridView dengan mainAxisExtent 330).
/// Kalau kartu ditekan, membuka BookDescriptionPage.
class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final bool isSeller;
  final VoidCallback? onEdit;

  const BookCard({
    Key? key,
    required this.book,
    this.isSeller = false,
    this.onEdit,
  }) : super(key: key);

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => BookDescriptionPage(book: book),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cover = book['cover'] as String?;
    final stock = (book['stock'] ?? 0) as int;
    final condition = (book['condition'] ?? 'Good') as String;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isSeller ? null : () => _openDetail(context),
        child: Container(
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
              if (isSeller && book['qc_status']?.toString() != 'approved') ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: book['qc_status']?.toString() == 'rejected'
                        ? const Color(0xFFFFE4E4)
                        : const Color(0xFFFFF2D8),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    book['qc_status']?.toString() == 'rejected'
                        ? 'REJECTED'
                        : 'PENDING REVIEW',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              Text(
                book['title'] ?? '-',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                book['author'] ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 9, color: Colors.grey),
              ),
              const Spacer(),
              Row(
                children: [
                  // Harga mengambil semua sisa ruang -> kondisi terdorong ke kanan
                  Expanded(
                    child: Text(
                      formatRupiah(book['price']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Bukan Flexible/Expanded, supaya lebarnya sebatas teks
                  // dan selalu menempel di tepi kanan.
                  Text(
                    condition,
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: conditionColor(condition),
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
                    backgroundColor: isSeller
                        ? const Color(0xFFF95200)
                        : const Color(0xFFE05627),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    // Font tombol disamakan dengan teks lain di kartu (Inter)
                    textStyle: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: isSeller
                      ? onEdit
                      : (stock > 0 ? () => addBookToCart(context, book) : null),
                  child: Text(
                    isSeller ? 'EDIT' : 'ADD TO CART',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.book, size: 40, color: Colors.white),
      ),
    );
  }
}
