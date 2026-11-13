import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reread/components/book_card.dart';
import 'package:reread/components/footer.dart';
import 'package:reread/components/topbar.dart';
import 'package:reread/pages/buyer_pages/genre_page.dart';
import 'package:reread/services/book_repository.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  static const primaryOrange = Color(0xFFE05627);

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  late Future<List<Map<String, dynamic>>> _booksFuture;

  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'Fiction',
      'image':
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&q=80',
      'fallbackColor': Color(0xFF2B4C3F),
    },
    {
      'name': 'Non-Fiction',
      'image':
          'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=800&q=80',
      'fallbackColor': Color(0xFF5A2A27),
    },
    {
      'name': 'Mystery',
      'image':
          'https://images.unsplash.com/photo-1773047747721-f75d546d7290?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=NHwxMjA3fDA%3D',
      'fallbackColor': Color(0xFF1F2D3A),
    },
    {
      'name': 'Biography',
      'image':
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800&q=80',
      'fallbackColor': Color(0xFF6E5338),
    },
    {
      'name': 'Children',
      'image':
          'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800&q=80',
      'fallbackColor': Color(0xFF8C6D53),
    },
    {
      'name': 'Young Adult',
      'image':
          'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80',
      'fallbackColor': Color(0xFF4A5D6E),
    },
    {
      'name': 'Comics & Graphic Novels',
      'genreValue': 'Comics & Graphic Novels',
      'image':
          'https://images.unsplash.com/photo-1612036782180-6f0b6cd846fe?w=800&q=80',
      'fallbackColor': Color(0xFF1E56A0),
    },
    {
      'name': 'Romance',
      'image':
          'https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00?w=800&q=80',
      'fallbackColor': Color(0xFF7A4B56),
    },
    {
      'name': 'Science & Tech',
      'image':
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80',
      'fallbackColor': Color(0xFF1D4E89),
    },
  ];

  @override
  void initState() {
    super.initState();
    _booksFuture = BookRepository.getBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _booksFuture = BookRepository.getBooks(refresh: true);
    });
  }

  void _navigateToGenre(String genreName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GenrePage(genre: genreName)),
    );
  }

  // Logika yang sama dengan search di HomePage (judul atau penulis)
  List<Map<String, dynamic>> _searchBooks(List<Map<String, dynamic>> books) {
    return books.where((b) {
      final title = (b['title'] ?? '').toString().toLowerCase();
      final author = (b['author'] ?? '').toString().toLowerCase();
      return title.contains(_query) || author.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    return Scaffold(
      appBar: CustomTopBar(activeNav: 'Categories'),
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
                    'Search your book by categories',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 22 : 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22201F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover well-loved books from readers near you.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar (sama seperti di HomePage)
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _query = value.trim().toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search by title or author',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kosong -> grid kategori, ada isi -> hasil buku
                  if (_query.isEmpty)
                    _buildCategoryGrid()
                  else
                    _buildSearchResults(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 16,
            mainAxisExtent: 180,
          ),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final displayName = category['name'] as String;
            final genreParam =
                (category['genreValue'] ?? displayName) as String;

            return _CategoryCard(
              title: displayName,
              imageUrl: category['image'] as String,
              fallbackColor: category['fallbackColor'] as Color,
              onTap: () => _navigateToGenre(genreParam),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _booksFuture,
      initialData: BookRepository.cached,
      builder: (context, snapshot) {
        if (snapshot.data == null &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: CircularProgressIndicator(color: primaryOrange),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Failed to load books.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _reload,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        final results = _searchBooks(snapshot.data ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${results.length} books available',
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Results',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Text(
                    'No books match your search.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
              )
            else
              _buildBookGrid(results),
          ],
        );
      },
    );
  }

  Widget _buildBookGrid(List<Map<String, dynamic>> books) => LayoutBuilder(
    builder: (context, constraints) {
      const double spacing = 12;
      const double minCardWidth = 170;
      const double maxCardWidth = 220;
      const double cardHeight = 330;

      final width = constraints.maxWidth - 0.5;

      final int columns = width < 700
          ? 2 // HP selalu 2
          : ((width + spacing) / (minCardWidth + spacing))
              .floor()
              .clamp(2, 5)
              .toInt();

      final double cardWidth = ((width - spacing * (columns - 1)) / columns)
        .clamp(0.0, maxCardWidth)
        .toDouble();

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final book in books)
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: BookCard(book: book),
            ),
        ],
      );
    },
  );
}

class _CategoryCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final Color fallbackColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.imageUrl,
    required this.fallbackColor,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: _isHovered
              ? (Matrix4.identity()..scale(1.015))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.fallbackColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.22 : 0.12),
                blurRadius: _isHovered ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: widget.fallbackColor),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.black.withOpacity(0.25),
                      ],
                      radius: 0.9,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.85),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
