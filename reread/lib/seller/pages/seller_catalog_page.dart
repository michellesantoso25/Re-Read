import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../component/top_bar.dart';

class SellerCatalogPage extends StatelessWidget {
  const SellerCatalogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EAE3),
      appBar: const CustomTopBar(activePage: 'Catalog'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
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

            // Search Bar
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

            // Sort Header
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
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                final books = [
                  {'title': 'The Midnight Library', 'author': 'Matt Haig', 'price': '\Rp 9.50', 'condition': ''},
                  {'title': 'Before the Coffee Gets Cold', 'author': 'Toshikazu Kawaguchi', 'price': '\Rp 8.00', 'condition': 'Very good'},
                  {'title': 'The Vanishing Half', 'author': 'Brit Bennett', 'price': '\Rp 11.25', 'condition': 'Very good'},
                  {'title': 'Klara and the Sun', 'author': 'Kazuo Ishiguro', 'price': '\Rp 10.00', 'condition': 'Very good'},
                  {'title': 'Circe', 'author': 'Madeline Miller', 'price': '\Rp 7.75', 'condition': 'Very good'},
                ];

                final book = books[index % 5];

                return _buildSellerBookCard(
                  context: context,
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

  // Book Card Component
  Widget _buildSellerBookCard({
    required BuildContext context,
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
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            author,
            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF888888)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
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
              onPressed: () {
                _showEditPopup(context); 
              },
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

  // Edit Form Dialog (Pop-up)
  void _showEditPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 450,
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
                        'Photos',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFFFF5500)),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2EB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFF944D), width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_library_outlined, size: 24, color: Color(0xFF333333)),
                        const SizedBox(height: 8),
                        Text(
                          'Drop cover photos here',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'JPG or PNG · up to 5 images',
                          style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF888888)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text('Book information', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Book title', 'Enter book title')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Category', 'Literary fiction')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Author', 'Enter author')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Edition', 'Enter edition')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField('ISBN', 'Enter isbn')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Language', 'English')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Selling price', 'Enter selling price')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Description', 'Enter description')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5500),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
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
  }

  // Reusable TextField for Dialog
  Widget _buildTextField(String label, String hint) {
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
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF999999)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: Color(0xFFFF5500)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}