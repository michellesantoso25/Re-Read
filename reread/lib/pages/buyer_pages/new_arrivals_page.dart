import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reread/components/book_card.dart';
import 'package:reread/components/footer.dart';
import 'package:reread/components/topbar.dart';
import 'package:reread/services/book_repository.dart';

class NewArrivalsPage extends StatefulWidget {
  const NewArrivalsPage({Key? key}) : super(key: key);

  @override
  State<NewArrivalsPage> createState() => _NewArrivalsPageState();
}

class _NewArrivalsPageState extends State<NewArrivalsPage> {
  static const primaryOrange = Color(0xFFE05627);

  // Jumlah maksimal buku di section New Releases (saat tidak memfilter)
  static const int _maxNewReleases = 15;

  static const List<String> _genres = [
    'Fiction',
    'Non-Fiction',
    'Mystery',
    'Biography',
    'Children',
    'Young Adult',
    'Comics & Graphic Novels',
    'Science & Tech',
    'Romance',
  ];

  // Label -> [min, max). max null = tanpa batas atas
  static const Map<String, List<int?>> _priceRanges = {
    'Under Rp 75.000': [0, 75000],
    'Rp 75.000 - 100.000': [75000, 100001],
    'Over Rp 100.000': [100001, null],
  };

  static const List<String> _conditions = ['Like new', 'Very good', 'Good'];

  static const List<String> _sortOptions = [
    'Recommended',
    'Newest',
    'Price: Low to High',
    'Price: High to Low',
  ];

  final TextEditingController _searchController = TextEditingController();

  late Future<List<Map<String, dynamic>>> _booksFuture;

  // Pilihan di checkbox (belum diterapkan) dan filter yang sudah diterapkan
  final Set<String> _pendingGenres = {};
  final Set<String> _pendingPrices = {};
  final Set<String> _pendingConditions = {};
  Set<String> _appliedGenres = {};
  Set<String> _appliedPrices = {};
  Set<String> _appliedConditions = {};

  String _query = '';
  String _sort = 'Recommended';
  String _bestsellerGenre = 'Fiction';
  bool _showAllReleases = false;
  bool _showAllBestsellers = false;

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

  num _priceOf(Map<String, dynamic> b) =>
      num.tryParse(b['price'].toString()) ?? 0;

  // Waktu terbaru antara created_at dan updated_at
  // (kalau salah satu tidak ada, dilewati)
  DateTime _latestActivity(Map<String, dynamic> b) {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final created =
        DateTime.tryParse((b['created_at'] ?? '').toString()) ?? epoch;
    final updated =
        DateTime.tryParse((b['updated_at'] ?? '').toString()) ?? epoch;
    return updated.isAfter(created) ? updated : created;
  }

  // N buku yang paling baru dibuat atau diupdate
  List<Map<String, dynamic>> _latest(
    List<Map<String, dynamic>> books, {
    int limit = _maxNewReleases,
  }) {
    final list = [...books];
    list.sort((a, b) => _latestActivity(b).compareTo(_latestActivity(a)));
    return list.take(limit).toList();
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> books) {
    return books.where((b) {
      // Genre
      final genre = (b['genre'] ?? '').toString().trim().toLowerCase();
      if (_appliedGenres.isNotEmpty &&
          !_appliedGenres.any((g) => g.toLowerCase() == genre)) {
        return false;
      }

      // Price
      if (_appliedPrices.isNotEmpty) {
        final price = _priceOf(b);
        final match = _appliedPrices.any((label) {
          final range = _priceRanges[label]!;
          final min = range[0]!;
          final max = range[1];
          return price >= min && (max == null || price < max);
        });
        if (!match) return false;
      }

      // Condition
      final condition = (b['condition'] ?? '').toString().trim().toLowerCase();
      if (_appliedConditions.isNotEmpty &&
          !_appliedConditions.any((c) => c.toLowerCase() == condition)) {
        return false;
      }

      // Search by title or author
      if (_query.isNotEmpty) {
        final title = (b['title'] ?? '').toString().toLowerCase();
        final author = (b['author'] ?? '').toString().toLowerCase();
        if (!title.contains(_query) && !author.contains(_query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _applySort(List<Map<String, dynamic>> books) {
    final list = [...books];
    switch (_sort) {
      case 'Newest':
        list.sort((a, b) => _latestActivity(b).compareTo(_latestActivity(a)));
        break;
      case 'Price: Low to High':
        list.sort((a, b) => _priceOf(a).compareTo(_priceOf(b)));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => _priceOf(b).compareTo(_priceOf(a)));
        break;
      default:
        // Recommended = urutan bawaan (terbaru dulu)
        break;
    }
    return list;
  }

  void _applyPending() {
    setState(() {
      _appliedGenres = {..._pendingGenres};
      _appliedPrices = {..._pendingPrices};
      _appliedConditions = {..._pendingConditions};
      _showAllReleases = false;
    });
  }

  void _resetFilters() {
    setState(() {
      _pendingGenres.clear();
      _pendingPrices.clear();
      _pendingConditions.clear();
      _appliedGenres = {};
      _appliedPrices = {};
      _appliedConditions = {};
      _searchController.clear();
      _query = '';
      _sort = 'Recommended';
      _showAllReleases = false;
    });
  }

  Future<void> _showMobileFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: .86,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8D1CC),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: _buildSidebar(mobile: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileFilterButton() {
    final count =
        _appliedGenres.length +
        _appliedPrices.length +
        _appliedConditions.length;
    return OutlinedButton(
      onPressed: _showMobileFilters,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF302D2B),
        side: const BorderSide(color: Color(0xFFE3D9D2)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.filter_list_rounded, size: 18),
          const SizedBox(width: 7),
          Text('Filter', style: GoogleFonts.inter(fontSize: 13)),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: primaryOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    return Scaffold(
      appBar: CustomTopBar(activeNav: 'New Arrivals'),
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
                    'New Arrivals',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 23 : 26,
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

                  // Search Bar
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
                                _showAllReleases = false;
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
                  const SizedBox(height: 20),

                  // Sidebar Filter + Main Content
                  if (isMobile) ...[
                    _mobileFilterButton(),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: _buildMainContent(),
                    ),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSidebar(),
                        const SizedBox(width: 20),
                        Expanded(child: _buildMainContent()),
                      ],
                    ),
                ],
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar({bool mobile = false}) {
    return Container(
      width: mobile ? double.infinity : 200,
      padding: mobile ? EdgeInsets.zero : const EdgeInsets.all(16),
      decoration: mobile
          ? null
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter books',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: _resetFilters,
                child: Text(
                  'Reset',
                  style: GoogleFonts.inter(fontSize: 10, color: primaryOrange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _filterSection('GENRE', _genres, _pendingGenres),
          const SizedBox(height: 12),
          _filterSection('PRICE', _priceRanges.keys.toList(), _pendingPrices),
          const SizedBox(height: 12),
          _filterSection('CONDITION', _conditions, _pendingConditions),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _applyPending();
                if (mobile && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Apply Filters',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
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

        final allBooks = snapshot.data ?? [];
        final filtered = _applySort(_applyFilters(allBooks));
        final isFiltering =
            _appliedGenres.isNotEmpty ||
            _appliedPrices.isNotEmpty ||
            _appliedConditions.isNotEmpty ||
            _query.isNotEmpty;

        // Tanpa filter: New Releases = 15 buku terbaru (dibuat/diupdate).
        // Dengan filter/search: semua hasil yang cocok.
        final releasePool = isFiltering
            ? filtered
            : _applySort(_latest(allBooks));
        final visible = (isFiltering || _showAllReleases)
            ? releasePool
            : releasePool.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Jumlah buku + Sort
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} books available',
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                ),
                _buildSortButton(),
              ],
            ),
            const SizedBox(height: 12),

            // New Releases / Results
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isFiltering ? 'Results' : 'New Releases',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isFiltering && releasePool.length > 5)
                  InkWell(
                    onTap: () =>
                        setState(() => _showAllReleases = !_showAllReleases),
                    child: Text(
                      _showAllReleases ? 'Show Less' : 'View All ->',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (releasePool.isEmpty)
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
              _bookGrid(visible),

            // Bestsellers (disembunyikan saat user sedang mencari/memfilter)
            if (!isFiltering) ...[
              const SizedBox(height: 28),
              _buildBestsellers(allBooks),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSortButton() {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    return PopupMenuButton<String>(
      tooltip: 'Sort books',
      onSelected: (value) => setState(() => _sort = value),
      itemBuilder: (context) => _sortOptions
          .map(
            (o) => PopupMenuItem<String>(
              value: o,
              child: Text(
                o,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: o == _sort ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isMobile ? 'Sort' : 'Sort: $_sort',
              style: GoogleFonts.inter(fontSize: 10),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildBestsellers(List<Map<String, dynamic>> allBooks) {
    // Belum ada data penjualan, jadi sementara pakai buku di genre terpilih.
    // Kalau nanti ada kolom penjualan (mis. sold_count), urutkan di sini.
    final byGenre = allBooks.where((b) {
      final genre = (b['genre'] ?? '').toString().trim().toLowerCase();
      return genre == _bestsellerGenre.toLowerCase();
    }).toList();
    final visible = _showAllBestsellers ? byGenre : byGenre.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bestsellers By Category',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (byGenre.length > 5)
              InkWell(
                onTap: () =>
                    setState(() => _showAllBestsellers = !_showAllBestsellers),
                child: Text(
                  _showAllBestsellers ? 'Show Less' : 'View All ->',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _genres.map((g) {
            final selected = g == _bestsellerGenre;
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() {
                _bestsellerGenre = g;
                _showAllBestsellers = false;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selected ? primaryOrange : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? primaryOrange : Colors.black26,
                  ),
                ),
                child: Text(
                  g,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: selected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (byGenre.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'No books in this category yet.',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
              ),
            ),
          )
        else
          _bookGrid(visible),
      ],
    );
  }

  Widget _bookGrid(List<Map<String, dynamic>> books) {
    return LayoutBuilder(
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
    );
  }

  Widget _filterSection(
    String title,
    List<String> options,
    Set<String> selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...options.map(
          (opt) => InkWell(
            onTap: () => setState(() {
              selected.contains(opt) ? selected.remove(opt) : selected.add(opt);
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: selected.contains(opt),
                      activeColor: primaryOrange,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (checked) => setState(() {
                        checked == true
                            ? selected.add(opt)
                            : selected.remove(opt);
                      }),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(opt, style: GoogleFonts.inter(fontSize: 10)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
