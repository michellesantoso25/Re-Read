import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:reread/pages/buyer_pages/genre_page.dart';

/// One tappable footer entry.
class _FooterItem {
  final String label;
  final VoidCallback onTap;
  const _FooterItem(this.label, this.onTap);
}

class CustomFooter extends StatelessWidget {
  const CustomFooter({Key? key}) : super(key: key);

  static const _maxWidth = 1200.0;

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  // ------------------------------------------------------------ navigation

  /// Main pages: replace the stack, same behaviour as the top bar.
  void _goMain(BuildContext context, String route) {
    Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
  }

  /// Info pages (such as FAQs): push so Back returns to where you were.
  void _goInfo(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  void _openGenre(BuildContext context, String genre) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => GenrePage(genre: genre),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // ----------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE05627);
    final isMobile = MediaQuery.sizeOf(context).width < 900;
    // Text is left-aligned in every column; the group of columns itself is
    // centred on the page (see the max width below).
    const alignRight = false;

    return Container(
      width: double.infinity,
      color: const Color(0xFF2C2D30),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 28 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMobile) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _topGenres(context, alignRight)),
                    const SizedBox(width: 20),
                    Expanded(child: _quickLinks(context, alignRight)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _companyLinks(context, alignRight)),
                    const SizedBox(width: 20),
                    Expanded(child: _supportLinks(context, alignRight)),
                  ],
                ),
                const SizedBox(height: 24),
                _brandAndContact(primaryOrange, alignRight),
              ] else
                LayoutBuilder(
                  builder: (context, c) {
                    // Same spacing between every column, and the whole group
                    // is centred, so no empty space piles up on either side.
                    final gap = SizedBox(
                      width: ((c.maxWidth - 520) / 4)
                          .clamp(16.0, 125.0)
                          .toDouble(),
                    );
                    return Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _topGenres(context, alignRight),
                            gap,
                            _quickLinks(context, alignRight),
                            gap,
                            _companyLinks(context, alignRight),
                            gap,
                            _supportLinks(context, alignRight),
                            gap,
                            _brandAndContact(primaryOrange, alignRight),
                          ],
                        ),
                      ),
                    );
                  },
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                    onTap: () =>
                        _launchURL('https://www.tiktok.com/@reread_com'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
        ),
      ),
    );
  }

  // --------------------------------------------------------------- columns

  Widget _footerColumn(
    String title,
    List<_FooterItem> items, {
    required bool alignRight,
  }) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: alignRight ? TextAlign.right : TextAlign.start,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        for (final item in items)
          _FooterLink(
            label: item.label,
            onTap: item.onTap,
            alignRight: alignRight,
          ),
      ],
    );
  }

  Widget _topGenres(BuildContext context, bool alignRight) {
    // Labels must match the genre values stored in the books table.
    const genres = [
      'Fiction',
      'Non-Fiction',
      'Mystery',
      'Biography',
      'Romance',
    ];
    return _footerColumn('Top Genres', [
      for (final g in genres) _FooterItem(g, () => _openGenre(context, g)),
    ], alignRight: alignRight);
  }

  Widget _quickLinks(BuildContext context, bool alignRight) =>
      _footerColumn('Quick Links', [
        _FooterItem('BestSellers', () => _goMain(context, '/newArrivals')),
        _FooterItem('New Arrivals', () => _goMain(context, '/newArrivals')),
        _FooterItem('Sell a Book', () => _goMain(context, '/sellBook')),
        _FooterItem('Categories', () => _goMain(context, '/categories')),
      ], alignRight: alignRight);

  Widget _companyLinks(BuildContext context, bool alignRight) =>
      _footerColumn('Company', [
        _FooterItem('About Us', () => _goMain(context, '/aboutUs')),
        _FooterItem('FAQs', () => _goInfo(context, '/faqs')),
      ], alignRight: alignRight);

  Widget _supportLinks(BuildContext context, bool alignRight) =>
      _footerColumn('Help & Support', [
        _FooterItem(
          'Contact Us',
          () => _launchURL('mailto:customer@reread.com'),
        ),
        _FooterItem('Track Orders', () => _goMain(context, '/profile')),
        _FooterItem('Returns & Refunds', () => _goInfo(context, '/faqs')),
      ], alignRight: alignRight);

  Widget _brandAndContact(Color primaryOrange, bool alignRight) => Column(
    crossAxisAlignment: alignRight
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Image.asset(
        'lib/assets/logo.png',
        height: 32,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Row(
          mainAxisSize: MainAxisSize.min,
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
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'Connect With Us',
        textAlign: alignRight ? TextAlign.right : TextAlign.start,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Email: customer@reread.com',
        textAlign: alignRight ? TextAlign.right : TextAlign.start,
        style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
      ),
      const SizedBox(height: 4),
      Text(
        'Phone: +62 8123456789\n(9am to 6pm, Mon-Fri)',
        textAlign: alignRight ? TextAlign.right : TextAlign.start,
        style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
      ),
    ],
  );
}

/// A footer link with a pointer cursor and a hover highlight.
class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool alignRight;

  const _FooterLink({
    required this.label,
    required this.onTap,
    required this.alignRight,
  });

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            widget.label,
            textAlign: widget.alignRight ? TextAlign.right : TextAlign.start,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: _hover ? Colors.white : Colors.white70,
              decoration: _hover
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
