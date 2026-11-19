import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reread/components/footer.dart';
import 'package:reread/components/topbar.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  static const _orange = Color(0xFFE05627);
  static const _ink = Color(0xFF22201F);
  static const _muted = Color(0xFF6F6A66);
  static const _bg = Color(0xFFEFE5DF);
  static const _card = Color(0xFFFFFDFB);
  static const _tint = Color(0xFFFAEEE7);
  static const _line = Color(0xFFD9D2CB);
  static const _maxWidth = 1100.0;

  void _go(BuildContext context, String route) {
    Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: const CustomTopBar(activeNav: 'Help & Support'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _breadcrumb(context),
                  const SizedBox(height: 14),
                  Text(
                    'About Us',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pre-loved books. New connections. Another chapter.',
                    style: GoogleFonts.inter(fontSize: 11, color: _muted),
                  ),
                  const SizedBox(height: 22),
                  _hero(context),
                  const SizedBox(height: 32),
                  _together(),
                  const SizedBox(height: 32),
                  _shelf(),
                  const SizedBox(height: 28),
                  _cta(context),
                ],
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- layout

  Widget _section({required Widget child}) {
    return Builder(
      builder: (context) {
        final mobile = MediaQuery.sizeOf(context).width < 700;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 16 : 32,
                vertical: 24,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Items side by side on wide screens (equal height), stacked on narrow ones.
  Widget _grid(List<Widget> items, {required bool wide, double gap = 16}) {
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            items[i],
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(child: items[i]),
          ],
        ],
      ),
    );
  }

  Widget _eyebrow(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: _orange,
        ),
      );

  Widget _primaryButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _orange,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_rounded, size: 12),
        ],
      ),
    );
  }

  Widget _secondaryButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        side: const BorderSide(color: _line),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ------------------------------------------------------------ breadcrumb

  Widget _breadcrumb(BuildContext context) {
    final style = GoogleFonts.inter(fontSize: 9.5, color: _muted);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () => _go(context, '/home'),
          child: Text('Home', style: style),
        ),
        Text('  /  ', style: style),
        Text('Company', style: style),
        Text('  /  ', style: style),
        Text(
          'About Us',
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: _ink,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ hero

  Widget _hero(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 820;

        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _eyebrow('FROM ONE READER TO ANOTHER'),
            const SizedBox(height: 10),
            Text(
              'Every book has more than one chapter.',
              style: GoogleFonts.inter(
                fontSize: wide ? 28 : 22,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: _ink,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Re:Read is a secondhand book marketplace connecting people who '
              'love to read with people ready to pass a book on. It\'s a place '
              'to find something unexpected, revisit an old favourite, or give '
              'a well-loved copy a new home.',
              style: GoogleFonts.inter(fontSize: 11, height: 1.55, color: _muted),
            ),
            const SizedBox(height: 10),
            Text(
              'We believe the story doesn\'t end when you turn the last page. '
              'The next chapter starts with another reader.',
              style: GoogleFonts.inter(fontSize: 11, height: 1.55, color: _muted),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _primaryButton('Explore Books', () => _go(context, '/home')),
                _secondaryButton('Sell a Book', () => _go(context, '/sellBook')),
              ],
            ),
          ],
        );

        final photo = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.55,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'lib/assets/about_hero.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF3E3D6), Color(0xFFD9B99B)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.auto_stories, size: 52, color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'A well-loved book. A new pair of hands.',
              style: GoogleFonts.inter(fontSize: 8.5, color: _muted),
            ),
          ],
        );

        return Container(
          padding: EdgeInsets.all(wide ? 32 : 18),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEAE3DD)),
          ),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 10, child: text),
                    const SizedBox(width: 40),
                    Expanded(flex: 11, child: photo),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [photo, const SizedBox(height: 18), text],
                ),
        );
      },
    );
  }

  // ------------------------------------------------- what brings us together

  Widget _together() {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 820;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'What brings us together',
              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: _ink),
            ),
            const SizedBox(height: 3),
            Text(
              'A love of books, and a little care for the people reading them next.',
              style: GoogleFonts.inter(fontSize: 10.5, color: _muted),
            ),
            const SizedBox(height: 14),
            _grid(
              [
                _valueCard(
                  Icons.menu_book_outlined,
                  'Good stories deserve another reader',
                  'A finished book can be someone else\'s next favourite. We make '
                      'room for discovery by helping pre-loved books move from one '
                      'shelf to another.',
                ),
                _valueCard(
                  Icons.people_outline_rounded,
                  'A marketplace with a human side',
                  'Behind every listing is a fellow reader. Thoughtful '
                      'descriptions, honest photos and respectful conversations '
                      'help everyone feel more confident.',
                ),
                _valueCard(
                  Icons.autorenew_rounded,
                  'More reading, less left unread',
                  'Buying secondhand makes use of books already in circulation. '
                      'Passing them on is a simple way to keep stories in use, not '
                      'sitting forgotten.',
                ),
              ],
              wide: wide,
            ),
          ],
        );
      },
    );
  }

  Widget _valueCard(IconData icon, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAE3DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _tint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: _orange),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: _ink),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.inter(fontSize: 10.5, height: 1.5, color: _muted),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------ one shelf to next

  Widget _shelf() {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 820;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'One shelf to the next',
              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: _ink),
            ),
            const SizedBox(height: 14),
            _grid(
              [
                _shelfStep(
                  '01',
                  'Find a book that speaks to you',
                  'Browse by genre, discover new arrivals, or search for a title '
                      'you\'ve been meaning to read. Check the edition, photos and '
                      'condition before you choose.',
                ),
                _shelfStep(
                  '02',
                  'Make space on your shelf',
                  'Ready to pass a book on? Add clear photos, describe any wear '
                      'and set your price. A helpful listing makes it easier for '
                      'the next reader to say yes.',
                ),
                _shelfStep(
                  '03',
                  'Give the story another chapter',
                  'Pack a sold book with care, share delivery updates and keep in '
                      'touch through your order. Small acts of care make a better '
                      'reading community.',
                ),
              ],
              wide: wide,
              gap: 28,
            ),
          ],
        );
      },
    );
  }

  Widget _shelfStep(String number, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: _orange),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: _ink),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: GoogleFonts.inter(fontSize: 10.5, height: 1.5, color: _muted),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------- cta

  Widget _cta(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 640;

        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your next chapter starts here.',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: _ink),
            ),
            const SizedBox(height: 4),
            Text(
              'Whether you\'re finding your next read or passing one on, '
              'there\'s a place for you at Re:Read.',
              style: GoogleFonts.inter(fontSize: 10.5, height: 1.45, color: _muted),
            ),
          ],
        );
        final button = _primaryButton(
          'Browse New Arrivals',
          () => _go(context, '/newArrivals'),
        );

        return Container(
          padding: EdgeInsets.symmetric(horizontal: wide ? 28 : 18, vertical: 22),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEAE3DD)),
          ),
          child: wide
              ? Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 20),
                    button,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [copy, const SizedBox(height: 14), button],
                ),
        );
      },
    );
  }
}