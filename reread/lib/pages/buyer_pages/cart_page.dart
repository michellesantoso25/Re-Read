import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reread/components/book_card.dart';
import 'package:reread/components/footer.dart';
import 'package:reread/components/topbar.dart';
import 'package:reread/services/cart_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  static const _orange = Color(0xFFFF4D00);
  static const _ink = Color(0xFF302D2B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE2D9),
      appBar: const CustomTopBar(activeNav: 'Cart'),
      body: AnimatedBuilder(
        animation: CartService.instance,
        builder: (context, _) {
          final cart = CartService.instance;
          final items = cart.items;
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 26,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your cart',
                            style: GoogleFonts.inter(
                              color: _ink,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items.isEmpty
                                ? 'Your next great read is waiting for you.'
                                : '${items.length} pre-loved ${items.length == 1 ? 'book' : 'books'} ready for their next chapter.',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF77716D),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final narrow = constraints.maxWidth < 760;
                              final cartItems = _itemsCard(context, items);
                              final summary = _summary(context, cart);
                              if (narrow) {
                                return Column(
                                  children: [
                                    cartItems,
                                    const SizedBox(height: 16),
                                    summary,
                                  ],
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 7, child: cartItems),
                                  const SizedBox(width: 20),
                                  SizedBox(width: 340, child: summary),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const CustomFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _itemsCard(BuildContext context, List<Map<String, dynamic>> items) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 500 ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cart items',
            style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 34),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 42,
                      color: Color(0xFFBDB4AD),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your cart is empty',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add a book and it will show up here.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...items.map((book) => _cartItem(book)),
        ],
      ),
    );
  }

  Widget _cartItem(Map<String, dynamic> book) {
    final cover = book['cover']?.toString();
    final price = book['price'];
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(width: 72, height: 104, child: _cover(cover)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title']?.toString() ?? 'Untitled book',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if ((book['author']?.toString() ?? '').isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    book['author'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
                TextButton(
                  onPressed: () => CartService.instance.remove(book),
                  style: TextButton.styleFrom(
                    foregroundColor: _orange,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 28),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text('Remove', style: GoogleFonts.inter(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRupiah(price),
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _summary(BuildContext context, CartService cart) {
    final hasItems = cart.itemCount > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order summary',
            style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          _summaryRow('Subtotal', formatRupiah(cart.subtotal)),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Total',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                formatRupiah(cart.subtotal),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: hasItems
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checkout is coming soon.')),
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE4DED9),
                elevation: 0,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Text(
                'Checkout',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Row(
    children: [
      Text(label, style: GoogleFonts.inter(fontSize: 14)),
      const Spacer(),
      Text(value, style: GoogleFonts.inter(fontSize: 14)),
    ],
  );

  Widget _cover(String? cover) {
    if (cover == null || cover.isEmpty) {
      return Container(
        color: const Color(0xFFE9E2DC),
        child: const Icon(Icons.book, color: Colors.white),
      );
    }
    if (cover.startsWith('http')) {
      return Image.network(
        cover,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return Image.asset(
      cover,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFE9E2DC),
    child: const Icon(Icons.book, color: Colors.white),
  );
}
