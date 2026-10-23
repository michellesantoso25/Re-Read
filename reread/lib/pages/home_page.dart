import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/topbar.dart';
import '../components/footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFECE6DF),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Subtitle
                  Text(
                    'Find your next chapter',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22201F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover well-loved books from readers near you.',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
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
                            decoration: InputDecoration(
                              hintText: 'Search by title, author, or ISBN',
                              hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Layout Sidebar Filter + Main Content
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sidebar Filter
                      Container(
                        width: 180,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filter books',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            _filterSection('GENRE', ['Fiction', 'Non-fiction', 'Mystery', 'Biography']),
                            const SizedBox(height: 12),
                            _filterSection('PRICE', ['Under \$10', '\$10-\$20', '\$20+']),
                            const SizedBox(height: 12),
                            _filterSection('CONDITION', ['Like new', 'Very good', 'Good']),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 32,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE05627),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {},
                                child: Text('Apply Filters', style: GoogleFonts.inter(fontSize: 11, color: Colors.white)),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Main Content Area
                      Expanded(
                        child: Column(
                          children: [
                            // Ads Banner
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD3622A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Put Ads Here',
                                  style: GoogleFonts.inter(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // New Releases Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('248 books available', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text('New Releases', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Text(
                                  'View All ->',
                                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFE05627), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Cards Grid
                            Row(
                              children: [
                                _bookCard('The Midnight Library', 'Matt Haig', '\$9.50'),
                                const SizedBox(width: 12),
                                _bookCard('Before the Coffee...', 'Toshikazu Kawaguchi', '\$8.00'),
                                const SizedBox(width: 12),
                                _bookCard('The Vanishing Half', 'Brit Bennett', '\$11.25'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer Component
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _filterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ...options.map((opt) => Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(value: false, onChanged: (_) {}, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
                const SizedBox(width: 6),
                Text(opt, style: GoogleFonts.inter(fontSize: 10)),
              ],
            )),
      ],
    );
  }

  Widget _bookCard(String title, String author, String price) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(child: Icon(Icons.book, size: 40, color: Colors.white)),
            ),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1),
            Text(author, style: GoogleFonts.inter(fontSize: 9, color: Colors.grey)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(price, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
                Text('Very good', style: GoogleFonts.inter(fontSize: 9, color: Colors.green)),
              ],
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
                onPressed: () {},
                child: Text('ADD TO CART', style: GoogleFonts.inter(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}