import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reread/components/footer.dart';
import 'package:reread/components/topbar.dart';

/// "Sell a Book" landing page: explains how selling works and leads to the seller dashboard.
class SellBookPage extends StatelessWidget {
  const SellBookPage({super.key});

  static const _orange = Color(0xFFE05627);
  static const _ink = Color(0xFF22201F);
  static const _muted = Color(0xFF6F6A66);
  static const _card = Color(0xFFF7F3EF);
  static const _tint = Color(0xFFFAEEE7);
  static const _beige = Color(0xFFF1E8E2);
  static const _heroBand = Color(0xFFF1E8E2);
  static const _line = Color(0xFFEAE3DD);
  static const _maxWidth = 1100.0;

  void _startNow(BuildContext context) {
    // TODO: navigate to the seller dashboard once it exists.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seller dashboard is coming soon.')),
    );
  }

  void _openHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomTopBar(activeNav: 'Sell a Book'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: _heroBand,
              child: _section(vertical: 36, child: _hero(context)),
            ),
            _section(child: _steps()),
            Container(color: _beige, child: _section(vertical: 36, child: _dashboard())),
            _section(child: _faq(context)),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- layout

  /// Centers content at a max width with responsive side padding.
  Widget _section({required Widget child, double vertical = 28}) {
    return Builder(
      builder: (context) {
        final mobile = MediaQuery.sizeOf(context).width < 700;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 16 : 32,
                vertical: vertical,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Items side by side on wide screens, stacked on narrow ones.
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
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: _orange,
        ),
      );

  Widget _startButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _orange,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => _startNow(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Start now',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded, size: 14),
        ],
      ),
    );
  }

  Widget _iconTile(IconData icon, {double size = 30}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _tint,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: size * 0.55, color: _orange),
    );
  }

  // ------------------------------------------------------------------ hero

  Widget _hero(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 820;

        final text = Padding(
          padding: EdgeInsets.only(right: wide ? 32 : 0, bottom: wide ? 0 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _eyebrow('SELL A BOOK ON RE:READ'),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: wide ? 44 : (c.maxWidth < 380 ? 26 : 30),
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: _ink,
                  ),
                  children: const [
                    TextSpan(text: 'Your bookshelf.\nTheir next '),
                    TextSpan(text: 'chapter.', style: TextStyle(color: _orange)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Make room for new stories by passing on the ones you\'ve '
                'loved. Turn your pre-loved books into someone else\'s next '
                'great read.',
                style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: _muted),
              ),
              const SizedBox(height: 18),
              _startButton(context),
              const SizedBox(height: 10),
              Text(
                'Your seller dashboard starts here.',
                style: GoogleFonts.inter(fontSize: 9.5, color: _muted),
              ),
            ],
          ),
        );

        final image = SizedBox(height: wide ? 320 : 220, child: _heroImage());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 11, child: text),
                  Expanded(flex: 9, child: image),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [text, image],
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _grid(
                [
                  _feature(
                    Icons.menu_book_outlined,
                    'Make space on your shelf',
                    'Give finished reads a new home and make room for what\'s next.',
                  ),
                  _feature(
                    Icons.sell_outlined,
                    'Sell on your terms',
                    'Choose your books, describe their condition and set your asking price.',
                  ),
                  _feature(
                    Icons.dashboard_customize_outlined,
                    'Keep it all together',
                    'Manage your listings and follow your orders in one seller dashboard.',
                  ),
                ],
                wide: wide,
                gap: 24,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _feature(IconData icon, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconTile(icon),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: GoogleFonts.inter(fontSize: 10, height: 1.4, color: _muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _heroPhoto() {
    Widget placeholder() => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF3E3D6), Color(0xFFD9B99B)],
            ),
          ),
          child: const Center(
            child: Icon(Icons.auto_stories, size: 56, color: Colors.white70),
          ),
        );

    return Image.asset(
      'lib/assets/sell_hero.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => placeholder(),
    );
  }

  Widget _heroImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _heroPhoto(),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_outlined, size: 15, color: _muted),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Good books deserve another reader.',
                      style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Pre-loved books, new adventures.',
                      style: GoogleFonts.inter(fontSize: 8.5, color: _muted),
                    ),
                  ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------- steps

  Widget _steps() {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 820;

        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _eyebrow('FROM SHELF TO NEW HOME'),
            const SizedBox(height: 6),
            Text(
              'A new chapter in three steps',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: _ink),
            ),
          ],
        );
        final note = Text(
          'Start with one book. Add more whenever you\'re ready to clear a little shelf space.',
          textAlign: wide ? TextAlign.right : TextAlign.left,
          style: GoogleFonts.inter(fontSize: 10.5, height: 1.4, color: _muted),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: note,
                  ),
                ],
              )
            else ...[
              title,
              const SizedBox(height: 8),
              note,
            ],
            const SizedBox(height: 16),
            _grid(
              [
                _stepCard(
                  '01',
                  'Create your listing',
                  'Add photos, the title and author, and an honest description of the book\'s condition.',
                ),
                _stepCard(
                  '02',
                  'Set your price & publish',
                  'Choose an asking price and put your book in front of readers browsing Re:Read.',
                ),
                _stepCard(
                  '03',
                  'Send it to its next reader',
                  'Follow the order details in your dashboard, pack your book with care and arrange delivery.',
                ),
              ],
              wide: wide,
            ),
          ],
        );
      },
    );
  }

  Widget _stepCard(String number, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: _orange),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: _ink),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: GoogleFonts.inter(fontSize: 10.5, height: 1.45, color: _muted),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- dashboard

  Widget _dashboard() {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 820;

        final preview = _previewCard();
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _eyebrow('MEET YOUR SELLER DASHBOARD'),
            const SizedBox(height: 8),
            Text(
              'Less juggling.\nMore books finding homes.',
              style: GoogleFonts.inter(
                fontSize: 22,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 18),
            _bullet(
              Icons.library_books_outlined,
              'Your listings, at a glance',
              'Create new listings, update prices and condition details, or keep a draft for later.',
            ),
            const SizedBox(height: 14),
            _bullet(
              Icons.inventory_2_outlined,
              'Stay on top of orders',
              'See which books have sold and keep track of what needs to be packed and sent.',
            ),
            const SizedBox(height: 14),
            _bullet(
              Icons.insights_outlined,
              'See your selling activity',
              'Review your sold books and sales history as your next chapter as a seller unfolds.',
            ),
          ],
        );

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [preview, const SizedBox(height: 28), copy],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: preview),
            const SizedBox(width: 56),
            Expanded(child: copy),
          ],
        );
      },
    );
  }

  Widget _bullet(IconData icon, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: _orange),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: _ink),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: GoogleFonts.inter(fontSize: 10.5, height: 1.4, color: _muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'A LOOK INSIDE',
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: _muted,
                  ),
                ),
              ),
              Text(
                'Illustrative preview',
                style: GoogleFonts.inter(fontSize: 8.5, color: _muted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your bookshelf, organised.',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: _ink),
                      ),
                    ),
                    const Icon(Icons.menu_book_outlined, size: 16, color: _orange),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _tab('My listings', active: true),
                    const SizedBox(width: 14),
                    _tab('Orders'),
                    const SizedBox(width: 14),
                    _tab('Sales history'),
                  ],
                ),
                const Divider(height: 14, color: _line),
                _listing('The Midnight Library', 'Very good · Rp 95.000', 'Active'),
                const SizedBox(height: 8),
                _listing('The Vanishing Half', 'Like new · Rp 88.000', 'Draft'),
                const Divider(height: 20, color: _line),
                Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 12, color: _orange),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Pick up where you left off. Your next listing is waiting.',
                        style: GoogleFonts.inter(fontSize: 9, color: _muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: active ? _orange : Colors.transparent, width: 1.5),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9.5,
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
          color: active ? _ink : _muted,
        ),
      ),
    );
  }

  Widget _listing(String title, String meta, String status) {
    final active = status == 'Active';
    return Row(
      children: [
        Container(
          width: 28,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF22303F),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Icon(Icons.menu_book, size: 12, color: Colors.white54),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: _ink),
              ),
              Text(
                meta,
                style: GoogleFonts.inter(fontSize: 9, color: _muted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE6F2E8) : const Color(0xFFF0ECE8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF3C8D40) : _muted,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------- faq

  Widget _faq(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 820;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'A few things before you begin',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: _ink),
                  ),
                ),
                InkWell(
                  onTap: () => _openHelp(context),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Help & Support',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _orange,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 11, color: _orange),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _grid(
              [
                _faqItem(
                  'What do I need to get started?',
                  'A book you\'re ready to pass on, clear photos, its title and author, and a price you\'re happy to ask.',
                ),
                _faqItem(
                  'How should I describe the condition?',
                  'Be specific about creases, notes or worn pages. Photograph any marks so readers know what to expect.',
                ),
                _faqItem(
                  'Where do I manage my books?',
                  'Select Start now to enter your seller dashboard. It\'s your place to add listings and follow your orders.',
                ),
              ],
              wide: wide,
              gap: 28,
            ),
            const SizedBox(height: 22),
            _cta(context, wide),
          ],
        );
      },
    );
  }

  Widget _faqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: _ink),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: GoogleFonts.inter(fontSize: 10.5, height: 1.45, color: _muted),
        ),
      ],
    );
  }

  Widget _cta(BuildContext context, bool wide) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'That book you loved? Pass it on.',
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: _ink),
        ),
        const SizedBox(height: 3),
        Text(
          'Open your seller dashboard and give your first book a new beginning.',
          style: GoogleFonts.inter(fontSize: 10.5, color: _muted),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: _beige,
        borderRadius: BorderRadius.circular(14),
      ),
      child: wide
          ? Row(
              children: [
                _iconTile(Icons.menu_book_outlined, size: 44),
                const SizedBox(width: 16),
                Expanded(child: copy),
                const SizedBox(width: 16),
                _startButton(context),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconTile(Icons.menu_book_outlined, size: 44),
                const SizedBox(height: 12),
                copy,
                const SizedBox(height: 14),
                _startButton(context),
              ],
            ),
    );
  }
}