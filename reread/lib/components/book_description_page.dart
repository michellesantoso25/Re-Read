import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reread/components/book_card.dart';
import 'package:reread/components/cart_feedback.dart';
import 'package:reread/components/footer.dart';
import 'package:reread/components/topbar.dart';

/// Halaman detail buku. Dibuka ketika BookCard ditekan.
class BookDescriptionPage extends StatelessWidget {
  final Map<String, dynamic> book;
  const BookDescriptionPage({Key? key, required this.book}) : super(key: key);

  static const _orange = Color(0xFFE05627);

  String _str(dynamic v, [String fallback = '-']) {
    final s = v?.toString().trim() ?? '';
    return s.isEmpty ? fallback : s;
  }

  List<String> _checklist() {
    final raw = book['condition_checklist'];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .split(RegExp(r'[\n;]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    return Scaffold(
      backgroundColor: const Color(0xFFECE6DF),
      appBar: const CustomTopBar(activeNav: 'Categories'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 40,
                vertical: isMobile ? 18 : 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: _buildCard(context),
                ),
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final cover = book['cover'] as String?;
    final stock = (book['stock'] ?? 0) as int;
    final condition = _str(book['condition'], 'Good');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _banner(cover),
          const SizedBox(height: 12),
          Text(
            _str(book['title']),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF302D2B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _str(book['author']),
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            'Synopsis',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _str(book['synopsis'], 'No Synopsis available.'),
            style: GoogleFonts.inter(fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 16),
          Text(
            'Book Information',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          _buildInfo(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatRupiah(book['price']),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF302D2B),
                  ),
                ),
              ),
              Text(
                condition,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: conditionColor(condition),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(
                      'BACK',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: stock > 0
                        ? () => addBookToCart(context, book)
                        : null,
                    child: Text(
                      stock > 0 ? 'ADD TO CART' : 'SOLD OUT',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    final checklist = _checklist();

    final category = _infoItem(
      'Category',
      _str(book['category'] ?? book['genre']),
    );
    final isbn = _infoItem('ISBN', _str(book['isbn']));
    final edition = _infoItem('Edition', _str(book['edition']));
    final language = _infoItem('Language', _str(book['language']));
    final checklistWidget = _checklistWidget(checklist);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 520) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [category, isbn])),
              Expanded(child: Column(children: [edition, language])),
              Expanded(child: checklistWidget),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Column(children: [category, isbn])),
                Expanded(child: Column(children: [edition, language])),
              ],
            ),
            checklistWidget,
          ],
        );
      },
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _checklistWidget(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition checklist',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        if (items.isEmpty)
          Text('-', style: GoogleFonts.inter(fontSize: 12))
        else
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: GoogleFonts.inter(fontSize: 12)),
                  Expanded(
                    child: Text(item, style: GoogleFonts.inter(fontSize: 12)),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  /// Banner cover: cover di tengah, sisi kiri-kanan diisi versi blur cover itu.
  Widget _banner(String? cover) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: (cover == null || cover.isEmpty)
            ? Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.book, size: 40, color: Colors.white),
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: _image(cover, BoxFit.cover, Alignment.center),
                  ),
                  Container(color: Colors.black26),
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.58,
                      heightFactor: 1,
                      child: _image(cover, BoxFit.cover, Alignment.topCenter),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _image(String cover, BoxFit fit, Alignment alignment) {
    Widget fallback(BuildContext _, Object __, StackTrace? ___) =>
        Container(color: Colors.grey.shade300);
    if (cover.startsWith('http')) {
      return Image.network(
        cover,
        fit: fit,
        alignment: alignment,
        errorBuilder: fallback,
      );
    }
    return Image.asset(
      cover,
      fit: fit,
      alignment: alignment,
      errorBuilder: fallback,
    );
  }
}
