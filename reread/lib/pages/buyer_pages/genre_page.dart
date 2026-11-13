import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reread/components/book_card.dart';
import 'package:reread/components/footer.dart';
import 'package:reread/components/topbar.dart';
import 'package:reread/services/book_repository.dart';

class GenrePage extends StatefulWidget {
  final String genre;
  const GenrePage({Key? key, required this.genre}) : super(key: key);

  @override
  State<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  List<Map<String, dynamic>>? _books;
  Object? _error;

  @override
  void initState() {
    super.initState();

    // Kalau data sudah ada di memori, langsung tampil tanpa loading
    final cached = BookRepository.cached;
    if (cached != null) {
      _books = BookRepository.byGenre(cached, widget.genre);
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final all = await BookRepository.getBooks();
      if (!mounted) return;
      setState(() => _books = BookRepository.byGenre(all, widget.genre));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    return Scaffold(
      appBar: CustomTopBar(activeNav: 'Categories', activeGenre: widget.genre),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFECE6DF),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 40,
                vertical: isMobile ? 18 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.genre,
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 23 : 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22201F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBody(),
                ],
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Text(
            'Failed to load books.\n$_error',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
          ),
        ),
      );
    }

    final books = _books;
    if (books == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFE05627)),
        ),
      );
    }

    if (books.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Text(
            'No books in ${widget.genre} yet.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${books.length} books available',
          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width < 700 ? 2 : (width < 1050 ? 3 : 4);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: books.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 330,
              ),
              itemBuilder: (context, i) => BookCard(book: books[i]),
            );
          },
        ),
      ],
    );
  }
}
