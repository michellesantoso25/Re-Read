import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:reread/components/footer.dart';
import 'package:reread/components/topbar.dart';

/// FAQs page: searchable questions grouped by topic, with a "Browse by topic"
/// menu that scrolls to each group.
///
/// Register in main.dart:  '/faqs': (context) => const FaqsPage(),
class FaqsPage extends StatefulWidget {
  const FaqsPage({super.key});

  @override
  State<FaqsPage> createState() => _FaqsPageState();
}

class _Qa {
  final String q;
  final String a;
  const _Qa(this.q, this.a);
}

class _Topic {
  final String id;
  final String title;
  final IconData icon;
  final List<_Qa> items;
  const _Topic(this.id, this.title, this.icon, this.items);
}

class _FaqsPageState extends State<FaqsPage> {
  static const _orange = Color(0xFFE05627);
  static const _ink = Color(0xFF22201F);
  static const _muted = Color(0xFF6F6A66);
  static const _bg = Color(0xFFEFE5DF);
  static const _card = Color(0xFFFFFDFB);
  static const _tint = Color(0xFFFAEEE7);
  static const _line = Color(0xFFEAE3DD);
  static const _maxWidth = 1100.0;

  static const _topics = <_Topic>[
    _Topic('buying', 'Buying & selling', Icons.shopping_bag_outlined, [
      _Qa(
        'How do I buy a secondhand book?',
        "Find a title you like, then review the seller's photos, condition "
            'notes, edition and price. Add it to your cart and confirm the '
            'delivery details and total at checkout. Each listing is one '
            'particular copy, so compare the details before relying on the '
            'title alone.',
      ),
      _Qa(
        'How do I list a book for sale?',
        'Choose Sell a Book and add the title, author, edition or ISBN, '
            'price and condition. Upload clear photos of the actual copy, '
            'including the cover, spine and any wear. Mention marks, notes or '
            'other flaws so the next reader knows what to expect.',
      ),
      _Qa(
        'Can I change or remove my listing?',
        'Review your listings from your seller account and update an '
            'available book when its price or condition changes. Remove books '
            'you can no longer sell. If a buyer has already placed an order, '
            'check that order and contact Help & Support before making '
            'changes that could affect it.',
      ),
    ]),
    _Topic('condition', 'Book condition', Icons.menu_book_outlined, [
      _Qa(
        'What do the condition labels mean?',
        'Like new generally means a clean copy with minimal signs of use. '
            'Very good may have light wear on the cover or pages. Good means '
            'more noticeable wear, such as creases, markings or yellowing, '
            'while the book remains readable. Always read the individual '
            'photos and described flaws as much as the label.',
      ),
      _Qa(
        'Are annotations, older editions or worn covers okay?',
        'They can be, as long as they are clearly described. Sellers should '
            'photograph highlighting, pencil notes, loose pages, cover damage '
            'and any other issues. Buyers should inspect the edition and '
            'check whether a specific version is needed for a course or '
            'collection. Ask the seller when a detail is unclear.',
      ),
    ]),
    _Topic('orders', 'Orders & shipping', Icons.local_shipping_outlined, [
      _Qa(
        'How much is shipping, and when will my book arrive?',
        'Shipping options, costs and any available delivery estimates are '
            'shown at checkout. They can vary by seller, delivery service and '
            'destination. Check the order details for updates; a delivery '
            'estimate is not a guaranteed arrival date.',
      ),
      _Qa(
        'Where can I track my order?',
        'Open Track Orders and select the purchase you want to check. '
            'Review the latest order status and any tracking link provided '
            'after dispatch. If there is no tracking update or the parcel '
            'seems delayed, contact the seller or Help & Support with your '
            'order reference.',
      ),
      _Qa(
        'Can I buy from different sellers or change my delivery address?',
        'Books from different sellers may be sent separately, with separate '
            'delivery charges or tracking details. Check the checkout summary '
            'before you pay. If your address is wrong, contact support as '
            'soon as you notice; once an order has been dispatched, a change '
            'may not be possible.',
      ),
    ]),
    _Topic('payments', 'Payments', Icons.credit_card_outlined, [
      _Qa(
        'Which payment methods can I use?',
        'Use one of the payment options displayed at checkout. Availability '
            'can depend on your location and the payment provider. Review the '
            'full amount, including delivery and any displayed charges, '
            'before confirming. Do not send payment to a seller through an '
            'unrelated link or personal transfer request.',
      ),
      _Qa(
        'My payment failed or I see a charge without an order. What should I do?',
        'Check your order history and the payment status before trying '
            'again. A pending authorisation is not always a completed charge. '
            'If a charge appears but no order is confirmed, contact Help & '
            'Support with the amount and transaction reference. Never share '
            'your full card number or verification code with anyone.',
      ),
      _Qa(
        'As a seller, where can I check payment details?',
        'Review the payment or payout information in your seller account '
            'and the details attached to the order. Any applicable fees and '
            'payout requirements should be checked before accepting a sale. '
            'Contact support if a payment status looks wrong, rather than '
            'shipping a replacement copy outside Re:Read.',
      ),
    ]),
    _Topic('returns', 'Returns & refunds', Icons.assignment_return_outlined, [
      _Qa(
        'What if the book arrives damaged or does not match the listing?',
        'Keep the packaging and take clear photos of the item, the damage '
            'and the shipping label. Open the order and contact Help & '
            'Support with the order reference and a short description. '
            'Check Return & Refund for the applicable process before sending '
            'anything back.',
      ),
      _Qa(
        'Can I return a book if I change my mind?',
        'Check the Return & Refund information and any terms shown with the '
            'order. Eligibility can depend on the reason for the return and '
            'the rights that apply to the purchase. Do not assume every used '
            'book can be returned simply because you changed your mind; ask '
            'support if you are unsure.',
      ),
      _Qa(
        'How do I check a refund or cancel an order?',
        'Contact support from the relevant order and explain what you need. '
            'Cancellation may depend on whether the seller has already '
            'dispatched the book. For an approved refund, check the order '
            "status and your payment provider's processing time, which can "
            'vary. Avoid returning a book until you have received '
            'instructions.',
      ),
    ]),
  ];

  final _search = TextEditingController();
  String _query = '';
  String _activeTopic = 'buying';

  /// Questions the reader has opened. Everything starts collapsed.
  final Set<String> _expanded = {};

  final Map<String, GlobalKey> _keys = {
    for (final t in _topics) t.id: GlobalKey(),
  };

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- actions

  List<_Qa> _visible(_Topic t) {
    if (_query.isEmpty) return t.items;
    final q = _query.toLowerCase();
    return t.items
        .where((e) => e.q.toLowerCase().contains(q) || e.a.toLowerCase().contains(q))
        .toList();
  }

  void _scrollTo(String topicId) {
    setState(() => _activeTopic = topicId);
    final ctx = _keys[topicId]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.02,
      );
    }
  }

  Future<void> _contact() async {
    final uri = Uri.parse('mailto:customer@reread.com');
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $uri');
    }
  }

  void _trackOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Track Orders is coming soon.')),
    );
  }

  // ----------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final crumb = GoogleFonts.inter(fontSize: 9.5, color: _muted);

    return Scaffold(
      backgroundColor: _bg,
      appBar: const CustomTopBar(activeNav: 'Help & Support'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: mobile ? 16 : 32,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context)
                                .pushNamedAndRemoveUntil('/home', (r) => false),
                            child: Text('Home', style: crumb),
                          ),
                          Text('  /  ', style: crumb),
                          Text('Help & Support', style: crumb),
                          Text('  /  ', style: crumb),
                          Text(
                            'FAQs',
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: _ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'FAQs',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'A little help for your next chapter. Find answers '
                        'about buying, selling and everything in between.',
                        style: GoogleFonts.inter(fontSize: 11, color: _muted),
                      ),
                      const SizedBox(height: 18),
                      _searchBox(),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, c) {
                          final wide = c.maxWidth >= 820;
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 220, child: _sidebar()),
                                const SizedBox(width: 28),
                                Expanded(child: _main()),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _topicChips(),
                              const SizedBox(height: 18),
                              _main(),
                              _lookingCard(),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _stillQuestion(),
                    ],
                  ),
                ),
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- search

  Widget _searchBox() {
    return TextField(
      controller: _search,
      onChanged: (v) => setState(() => _query = v.trim()),
      style: GoogleFonts.inter(fontSize: 11.5, color: _ink),
      decoration: InputDecoration(
        hintText: 'Search questions, e.g. book condition or tracking an order',
        hintStyle: GoogleFonts.inter(fontSize: 11, color: _muted),
        prefixIcon: const Icon(Icons.search, size: 17, color: _muted),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close, size: 16, color: _muted),
                onPressed: () {
                  _search.clear();
                  setState(() => _query = '');
                },
              ),
        filled: true,
        fillColor: _card,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _orange),
        ),
      ),
    );
  }

  // --------------------------------------------------------------- sidebar

  Widget _sidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
                child: Text(
                  'Browse by topic',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
              ),
              for (final t in _topics) _sidebarItem(t),
            ],
          ),
        ),
        _lookingCard(),
      ],
    );
  }

  Widget _sidebarItem(_Topic t) {
    final active = t.id == _activeTopic;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => _scrollTo(t.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: active ? _tint : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(t.icon, size: 14, color: active ? _orange : _muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t.title,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  color: active ? _orange : _ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lookingCard() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Looking for your book?',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: _ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Keep your order reference handy when you contact us about a '
            'purchase.',
            style: GoogleFonts.inter(fontSize: 9.5, height: 1.45, color: _muted),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _trackOrders,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Track Orders',
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
        ],
      ),
    );
  }

  /// Topic menu for narrow screens.
  Widget _topicChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final t in _topics)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  t.title,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: t.id == _activeTopic ? _orange : _ink,
                  ),
                ),
                selected: t.id == _activeTopic,
                selectedColor: _tint,
                backgroundColor: _card,
                showCheckmark: false,
                side: const BorderSide(color: _line),
                onSelected: (_) => _scrollTo(t.id),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ main

  Widget _main() {
    final shown = <Widget>[];
    for (final t in _topics) {
      final items = _visible(t);
      if (items.isEmpty) continue;
      shown.add(_section(t, items));
    }

    if (shown.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _line),
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 28, color: _muted),
            const SizedBox(height: 10),
            Text(
              'No questions match "$_query".',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different word, or contact us and we will help.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 10.5, color: _muted),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: shown,
    );
  }

  Widget _section(_Topic t, List<_Qa> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            key: _keys[t.id],
            children: [
              Icon(t.icon, size: 16, color: _orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
              ),
              Text(
                '${items.length} question${items.length == 1 ? '' : 's'}',
                style: GoogleFonts.inter(fontSize: 9, color: _muted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++)
                  _qaRow('${t.id}:${items[i].q}', items[i], last: i == items.length - 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qaRow(String id, _Qa qa, {required bool last}) {
    final expanded = _expanded.contains(id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() {
            if (!_expanded.remove(id)) _expanded.add(id);
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    qa.q,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(expanded ? Icons.remove : Icons.add, size: 16, color: _muted),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 44, 16),
            child: Text(
              qa.a,
              style: GoogleFonts.inter(fontSize: 10.5, height: 1.6, color: _muted),
            ),
          ),
        if (!last) const Divider(height: 1, color: _line),
      ],
    );
  }

  // ------------------------------------------------------ still a question

  Widget _stillQuestion() {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 640;

        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Still have a question?',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tell us what you need help with. For order questions, include '
              'your order reference so we can find the right details.',
              style: GoogleFonts.inter(fontSize: 10, height: 1.45, color: _muted),
            ),
          ],
        );

        final button = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _orange,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: _contact,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contact Us',
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 12),
            ],
          ),
        );

        return Container(
          padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 18, vertical: 20),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _line),
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