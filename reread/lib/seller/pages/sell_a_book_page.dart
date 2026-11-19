import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../component/top_bar.dart'; 

class SellABookPage extends StatefulWidget {
  const SellABookPage({Key? key}) : super(key: key);

  @override
  State<SellABookPage> createState() => _SellABookPageState();
}

class _SellABookPageState extends State<SellABookPage> {
  bool noMissingPages = false;
  bool noWriting = false;
  bool coverFirmly = false;
  bool noWaterDamage = false;
  bool smokeFree = false;

  final Color primaryOrange = const Color(0xFFFF5500);
  final Color bgColor = const Color(0xFFF1EAE3);

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
            // Header Text
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

            // Main Content Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Photos Card
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
                        Text(
                          'Photos',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF2EB), 
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFF944D), width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.photo_library_outlined, size: 32, color: Color(0xFF333333)),
                              const SizedBox(height: 12),
                              Text(
                                'Drop cover photos here',
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'JPG or PNG - up to 5 images',
                                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF888888)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                //Book Information Form
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
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
                        ),
                        const SizedBox(height: 24),

                        // Form Fields Grid
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Book title', 'Enter book title')),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('Category', 'Literary fiction')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Author', 'Enter author')),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('Edition', 'Enter edition')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('ISBN', 'Enter isbn')),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('Language', 'English')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Selling price', 'Enter selling price')),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('Description', 'Enter description')),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Condition Checklist
                        Text(
                          'Condition checklist',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
                        ),
                        const SizedBox(height: 16),
                        _buildCheckbox('No missing pages', noMissingPages, (val) => setState(() => noMissingPages = val!)),
                        _buildCheckbox('No writing or highlighting', noWriting, (val) => setState(() => noWriting = val!)),
                        _buildCheckbox('Cover firmly attached', coverFirmly, (val) => setState(() => coverFirmly = val!)),
                        _buildCheckbox('No water damage', noWaterDamage, (val) => setState(() => noWaterDamage = val!)),
                        _buildCheckbox('Smoke-free home', smokeFree, (val) => setState(() => smokeFree = val!)),
                        const SizedBox(height: 32),

                        // Publish Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                            },
                            child: Text(
                              'Publish listing',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44, 
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF999999)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: primaryOrange),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF333333)),
          ),
        ],
      ),
    );
  }
}