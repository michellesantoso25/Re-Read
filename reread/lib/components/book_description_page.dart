import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reread/components/book_card.dart';
import 'package:reread/components/cart_feedback.dart';
import 'package:reread/components/footer.dart';
import 'package:reread/components/topbar.dart';
import 'package:reread/services/seller_repository.dart';

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
    final pageWidth = MediaQuery.sizeOf(context).width;
    final isWide = pageWidth >= 860;
    return Scaffold(
      backgroundColor: const Color(0xFFECE6DF),
      appBar: const CustomTopBar(activeNav: 'Categories'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pageWidth < 520 ? 12 : (isWide ? 32 : 20),
                vertical: isWide ? 32 : 18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: _buildCard(context, isWide: isWide),
                ),
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required bool isWide}) {
    final cover = book['cover']?.toString();
    final stock = (book['stock'] as num?)?.toInt() ?? 0;
    final condition = _str(book['condition'], 'Good');

    return Container(
      padding: EdgeInsets.all(isWide ? 24 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _banner(cover)),
                const SizedBox(width: 28),
                Expanded(
                  flex: 6,
                  child: _buildDetails(context, stock, condition),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _banner(cover),
                const SizedBox(height: 16),
                _buildDetails(context, stock, condition),
              ],
            ),
    );
  }

  Widget _buildDetails(BuildContext context, int stock, String condition) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _str(book['title']),
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF302D2B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _str(book['author']),
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          _sellerCard(),
          const SizedBox(height: 18),
          Text(
            'Synopsis',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            _str(book['synopsis'], 'No Synopsis available.'),
            style: GoogleFonts.inter(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 18),
          Text(
            'Book Information',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildInfo(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatRupiah(book['price']),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF302D2B),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  condition,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: conditionColor(condition),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
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
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 42,
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
      );

  Widget _sellerCard() {
    final sellerId = book['seller_id']?.toString().trim() ?? '';
    if (sellerId.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<Map<String, dynamic>?>(
      future: SellerRepository.forBook(book),
      builder: (context, snapshot) {
        final seller = snapshot.data;
        final name = SellerRepository.displayName(book, profile: seller);
        final avatarUrl = seller?['avatar_url']?.toString();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7F1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF0E3DA)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE9E2DC),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? const Icon(Icons.person_outline, color: _orange, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sold by',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      snapshot.connectionState == ConnectionState.waiting
                          ? 'Loading seller…'
                          : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  /// Keep the cover in its natural portrait ratio instead of cropping it into
  /// a wide banner. BoxFit.contain preserves the original image proportions.
  Widget _banner(String? cover) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 0.72,
        child: Container(
          color: const Color(0xFFF7F3EF),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          child: (cover == null || cover.isEmpty)
              ? Icon(Icons.book, size: 48, color: Colors.grey.shade400)
              : _image(cover, BoxFit.contain, Alignment.center),
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
