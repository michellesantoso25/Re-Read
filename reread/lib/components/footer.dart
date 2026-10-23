import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({Key? key}) : super(key: key);

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE05627);

    return Container(
      width: double.infinity, // Memastikan footer melebar memenuhi layar
      color: const Color(0xFF2C2D30),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        children: [
          // Baris Utama Kolom Footer (Kebagi Rata dari Kiri ke Kanan)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Genres
              Expanded(
                flex: 2,
                child: _footerColumn('Top Genres', [
                  'Fiction',
                  'Non-fiction',
                  'Mystery',
                  'Biography',
                  'Romance'
                ]),
              ),

              // Quick Links
              Expanded(
                flex: 2,
                child: _footerColumn('Quick Links', [
                  'BestSellers',
                  'New Arrivals',
                  'Sell a Book',
                  'Categories'
                ]),
              ),

              // Company
              Expanded(
                flex: 2,
                child: _footerColumn('Company', ['About Us', 'FAQs', 'Teams']),
              ),

              // Help & Support
              Expanded(
                flex: 2,
                child: _footerColumn('Help & Support', [
                  'Contact Us',
                  'Track Orders',
                  'Terms & Conditions',
                  'Privacy Policy',
                  'Return & Refund'
                ]),
              ),

              // Re:Read Brand & Contact Info (Kanan Ujung)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'lib/assets/logo.png',
                      height: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(color: primaryOrange, width: 2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Re:Read',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Connect With Us',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: customer@reread.com',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phone: +62 8123456789\n(9am to 6pm, Mon-Fri)',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),

          // Follow Us Section
          Text(
            'Follow Us',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),

          // Social Media Buttons (Instagram & TikTok)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Instagram
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _launchURL('https://instagram.com/reread_com'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE1306C),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.instagram,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '@reread_com',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // TikTok
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('TikTok Re:Read coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.tiktok,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '@reread_com',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            '© 2024 Re:Read. Pre-loved books, new adventures.',
            style: GoogleFonts.inter(fontSize: 10, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _footerColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                link,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
              ),
            )),
      ],
    );
  }
}