import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reread/main.dart';
import '../component/top_bar.dart';

class SellABookPage extends StatefulWidget {
  const SellABookPage({Key? key}) : super(key: key);

  @override
  State<SellABookPage> createState() => _SellABookPageState();
}

class _SellABookPageState extends State<SellABookPage> {
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _authorController = TextEditingController();
  final _editionController = TextEditingController();
  final _isbnController = TextEditingController();
  final _languageController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool noMissingPages = false;
  bool noWriting = false;
  bool coverFirmly = false;
  bool noWaterDamage = false;
  bool smokeFree = false;

  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  bool _isSubmitting = false;

  final Color primaryOrange = const Color.fromRGBO(249, 82, 0, 1);
  final Color bgColor = const Color(0xFFF0E5DD);

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _authorController.dispose();
    _editionController.dispose();
    _isbnController.dispose();
    _languageController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedFileName = picked.name;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  List<String> _buildChecklistArray() {
    final list = <String>[];
    if (noMissingPages) list.add('No missing pages');
    if (noWriting) list.add('No writing or highlighting');
    if (coverFirmly) list.add('Cover firmly attached');
    if (noWaterDamage) list.add('No water damage');
    if (smokeFree) list.add('Smoke-free home');
    return list;
  }

  String _determineCondition() {
    final count = _buildChecklistArray().length;
    if (count >= 4) return 'Like new';
    if (count >= 2) return 'Very good';
    return 'Good';
  }

  Future<void> _publishListing() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first to publish a book.')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final priceText = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final price = int.tryParse(priceText);
    if (title.isEmpty || author.isEmpty || price == null || price < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Title and author are required; minimum selling price is Rp 1.000.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Upload clear photos of the actual book before listing.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String coverUrl = '';

      if (_selectedImageBytes != null) {
        final ext = (_selectedFileName ?? 'cover.jpg')
            .split('.')
            .last
            .toLowerCase();
        final filePath =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';

        await supabase.storage
            .from('book-covers')
            .uploadBinary(
              filePath,
              _selectedImageBytes!,
              fileOptions: FileOptions(
                contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
                upsert: true,
              ),
            );

        coverUrl = supabase.storage.from('book-covers').getPublicUrl(filePath);
      }

      await supabase.from('books').insert({
        'seller_id': user.id,
        'title': title,
        'author': author,
        'year': DateTime.now().year,
        'genre': _categoryController.text.trim().isEmpty
            ? 'Literary fiction'
            : _categoryController.text.trim(),
        'condition': _determineCondition(),
        'synopsis': _descriptionController.text.trim(),
        'stock': 1,
        'price': price,
        'cover': coverUrl,
        'qc_status': 'pending_review',
        'edition': _editionController.text.trim().isEmpty
            ? 'Paperback'
            : _editionController.text.trim(),
        'isbn': _isbnController.text.trim(),
        'language': _languageController.text.trim().isEmpty
            ? 'English'
            : _languageController.text.trim(),
        'condition_checklist': _buildChecklistArray(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Listing submitted for review. It will appear in the marketplace after approval.',
          ),
          backgroundColor: Color(0xFF1B8A5A),
        ),
      );

      Navigator.pushReplacementNamed(context, '/seller_catalog_page');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to publish book: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomTopBar(activePage: 'Sell a Book'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sell a book',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Give your book a new reader. Clear details help it sell faster.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF7A7A7A),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KIRI: Photos Card
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
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
                              'Photos',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C2C2C),
                              ),
                            ),
                            if (_selectedImageBytes != null)
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Text(
                                    'Change',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryOrange,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _pickImage,
                            child: Container(
                              height: 300,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF2EB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFF944D),
                                  width: 1.5,
                                ),
                              ),
                              child: _selectedImageBytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.memory(
                                        _selectedImageBytes!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.photo_library_outlined,
                                          size: 32,
                                          color: Color(0xFF333333),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Drop cover photos here',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2C2C2C),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'JPG or PNG - up to 5 images',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: const Color(0xFF888888),
                                          ),
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
                const SizedBox(width: 24),

                // KANAN: Book Information Form
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book information',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'Book title',
                                'Enter book title',
                                _titleController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                'Category',
                                'Literary fiction',
                                _categoryController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'Author',
                                'Enter author',
                                _authorController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                'Edition',
                                'Enter edition',
                                _editionController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'ISBN',
                                'Enter isbn',
                                _isbnController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                'Language',
                                'English',
                                _languageController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'Selling price',
                                'Enter selling price',
                                _priceController,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                'Description',
                                'Enter description',
                                _descriptionController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        Text(
                          'Condition checklist',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCheckbox(
                          'No missing pages',
                          noMissingPages,
                          (val) => setState(() => noMissingPages = val!),
                        ),
                        _buildCheckbox(
                          'No writing or highlighting',
                          noWriting,
                          (val) => setState(() => noWriting = val!),
                        ),
                        _buildCheckbox(
                          'Cover firmly attached',
                          coverFirmly,
                          (val) => setState(() => coverFirmly = val!),
                        ),
                        _buildCheckbox(
                          'No water damage',
                          noWaterDamage,
                          (val) => setState(() => noWaterDamage = val!),
                        ),
                        _buildCheckbox(
                          'Smoke-free home',
                          smokeFree,
                          (val) => setState(() => smokeFree = val!),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : _publishListing,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Publish listing',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.inter(fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF999999),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: primaryOrange, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: primaryOrange,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primaryOrange;
                }
                return Colors.white;
              }),
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
