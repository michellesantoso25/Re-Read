import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reread/components/book_card.dart';
import 'package:reread/main.dart';
import '../component/top_bar.dart';

class SellerCatalogPage extends StatefulWidget {
  const SellerCatalogPage({Key? key}) : super(key: key);

  @override
  State<SellerCatalogPage> createState() => _SellerCatalogPageState();
}

class _SellerCatalogPageState extends State<SellerCatalogPage> {
  static const Color bgColor = Color(0xFFF0E5DD);
  static const Color primaryOrange = Color(0xFFF95200);

  List _books = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _fetchSellerBooks();
  }

  String _safeStr(dynamic val) {
    if (val == null) return '';
    return '$val';
  }

  Future<void> _fetchSellerBooks() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _books = [];
          _isLoading = false;
        });
        return;
      }

      final response = await supabase
          .from('books')
          .select()
          .eq('seller_id', user.id)
          .order('id', ascending: false);

      if (!mounted) return;
      setState(() {
        _books = (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load catalog: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  List get _filteredBooks {
    final query = _searchQuery.trim().toLowerCase();
    final list = _books.where((item) {
      if (query.isEmpty) return true;
      final book = item as Map;
      final title = _safeStr(book['title']).toLowerCase();
      final author = _safeStr(book['author']).toLowerCase();
      final isbn = _safeStr(book['isbn']).toLowerCase();
      return title.contains(query) || author.contains(query) || isbn.contains(query);
    }).toList();

    list.sort((a, b) {
      final priceA = num.tryParse(_safeStr((a as Map)['price'])) ?? 0;
      final priceB = num.tryParse(_safeStr((b as Map)['price'])) ?? 0;
      return _sortAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final displayedBooks = _filteredBooks;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomTopBar(activePage: 'Catalog'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 650;
          final isTablet = constraints.maxWidth >= 650 && constraints.maxWidth < 1050;
          final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 40.0);
          final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 5);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Catalog',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Trusted seller · 4.9 rating · ${_books.length} books listed',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF7A7A7A),
                  ),
                ),
                const SizedBox(height: 20),

                // Search Bar
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF888888), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Search by title, author, or ISBN',
                            hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF888888)),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Sort Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${displayedBooks.length} books available',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF888888)),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _sortAscending = !_sortAscending),
                      child: Row(
                        children: [
                          Text(
                            _sortAscending ? 'Sort: Lowest Price' : 'Sort: Highest Price',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C2C2C),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 15,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: CircularProgressIndicator(color: primaryOrange),
                    ),
                  )
                else if (displayedBooks.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.menu_book_outlined, size: 42, color: Color(0xFF999999)),
                        const SizedBox(height: 12),
                        Text(
                          _books.isEmpty ? 'No books listed yet' : 'No matching books found',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _books.isEmpty
                              ? 'Start selling by adding your first book.'
                              : 'Try searching with a different keyword.',
                          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7A7A7A)),
                        ),
                        if (_books.isEmpty) ...[
                          const SizedBox(height: 18),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: () => Navigator.pushReplacementNamed(context, '/sell_a_book_page'),
                            child: Text(
                              'Sell a Book',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 325,
                    ),
                    itemCount: displayedBooks.length,
                    itemBuilder: (context, index) {
                      final book = Map<String, dynamic>.from(displayedBooks[index] as Map);
                      return BookCard(
                        book: book,
                        isSeller: true,
                        onEdit: () => _showEditPopup(context, book),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditPopup(BuildContext context, Map book) {
    final titleCtrl = TextEditingController(text: _safeStr(book['title']));
    final genreCtrl = TextEditingController(text: _safeStr(book['genre']));
    final authorCtrl = TextEditingController(text: _safeStr(book['author']));
    final editionCtrl = TextEditingController(text: _safeStr(book['edition']));
    final isbnCtrl = TextEditingController(text: _safeStr(book['isbn']));
    final langCtrl = TextEditingController(text: _safeStr(book['language']));
    final priceCtrl = TextEditingController(text: _safeStr(book['price']));
    final descCtrl = TextEditingController(text: _safeStr(book['synopsis']));

    Uint8List? newImageBytes;
    String? newFileName;
    bool isUpdating = false;
    final currentCover = _safeStr(book['cover']);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickNewCover() async {
              final picker = ImagePicker();
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 1200,
                imageQuality: 85,
              );
              if (picked == null) return;
              final bytes = await picked.readAsBytes();
              setDialogState(() {
                newImageBytes = bytes;
                newFileName = picked.name;
              });
            }

            Future<void> updateBook() async {
              final user = supabase.auth.currentUser;
              if (user == null) return;

              setDialogState(() => isUpdating = true);
              try {
                String coverUrl = currentCover;

                if (newImageBytes != null) {
                  final ext = (newFileName ?? 'cover.jpg').split('.').last.toLowerCase();
                  final filePath = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';

                  await supabase.storage.from('book-covers').uploadBinary(
                        filePath,
                        newImageBytes!,
                        fileOptions: FileOptions(
                          contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
                          upsert: true,
                        ),
                      );

                  coverUrl = supabase.storage.from('book-covers').getPublicUrl(filePath);
                }

                final cleanPrice = priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

                await supabase.from('books').update({
                  'title': titleCtrl.text.trim(),
                  'genre': genreCtrl.text.trim(),
                  'author': authorCtrl.text.trim(),
                  'edition': editionCtrl.text.trim(),
                  'isbn': isbnCtrl.text.trim(),
                  'language': langCtrl.text.trim(),
                  'price': int.tryParse(cleanPrice) ?? book['price'],
                  'synopsis': descCtrl.text.trim(),
                  'cover': coverUrl,
                }).eq('id', book['id']);

                if (!mounted) return;
                Navigator.of(dialogContext).pop();
                await _fetchSellerBooks();

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Book updated successfully!'),
                    backgroundColor: Color(0xFF1B8A5A),
                  ),
                );
              } catch (e) {
                setDialogState(() => isUpdating = false);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update book: $e'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Edit Book',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: primaryOrange),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Photo Drop Area
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: pickNewCover,
                          child: Container(
                            height: 110,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE1D2).withOpacity(0.45),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryOrange, width: 1.2),
                            ),
                            child: newImageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.memory(newImageBytes!, fit: BoxFit.cover),
                                  )
                                : currentCover.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(currentCover, fit: BoxFit.cover),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.photo_library_outlined, size: 24, color: Color(0xFF333333)),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Change cover photo',
                                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'JPG or PNG · max 5 MB',
                                            style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF888888)),
                                          ),
                                        ],
                                      ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text('Book information', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(child: _buildTextField('Book title', titleCtrl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField('Category', genreCtrl)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(child: _buildTextField('Author', authorCtrl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField('Edition', editionCtrl)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(child: _buildTextField('ISBN', isbnCtrl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField('Language', langCtrl)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(child: _buildTextField('Selling price (Rp)', priceCtrl, isNumber: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField('Description', descCtrl)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: isUpdating ? null : updateBook,
                          child: isUpdating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Update',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.inter(fontSize: 12),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: primaryOrange),
              ),
            ),
          ),
        ),
      ],
    );
  }
}