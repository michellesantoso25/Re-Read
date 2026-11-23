import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:reread/components/book_card.dart';
import 'package:reread/components/footer.dart';
import 'package:reread/components/topbar.dart';
import 'package:reread/services/cart_service.dart';
import 'package:reread/services/seller_repository.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const _orange = Color(0xFFE94E0B);
  static const _ink = Color(0xFF302D2B);
  static const _shippingOptions = <_ShippingOption>[
    _ShippingOption(
      name: 'Regular',
      code: 'regular',
      detail: '3–5 business days',
      price: 18000,
      icon: Icons.local_shipping_outlined,
    ),
    _ShippingOption(
      name: 'Express',
      code: 'express',
      detail: '1–2 business days',
      price: 30000,
      icon: Icons.bolt_rounded,
    ),
    _ShippingOption(
      name: 'Economy',
      code: 'economy',
      detail: '5–7 business days',
      price: 12000,
      icon: Icons.inventory_2_outlined,
    ),
    _ShippingOption(
      name: 'Seller covers shipping',
      code: 'seller',
      detail: 'Buyer only pays for the books',
      price: 0,
      icon: Icons.storefront_outlined,
    ),
  ];

  static const _paymentOptions = <_PaymentOption>[
    _PaymentOption(
      name: 'QRIS',
      detail: 'Scan a QR code to pay',
      icon: Icons.qr_code_2_rounded,
    ),
    _PaymentOption(
      name: 'E-Wallet',
      detail: 'GoPay, ShopeePay, DANA, OVO',
      icon: Icons.phone_iphone_rounded,
    ),
    _PaymentOption(
      name: 'Credit/Debit Card',
      detail: 'Visa, Mastercard, and more',
      icon: Icons.credit_card_outlined,
    ),
    _PaymentOption(
      name: 'Virtual Account',
      detail: 'Bank transfer via virtual account',
      icon: Icons.account_balance_outlined,
    ),
  ];

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _voucherController = TextEditingController();
  final Map<String, int> _selectedShippingBySeller = {};
  String _selectedPayment = 'QRIS';
  bool _hasMainAddress = false;
  String? _voucherError;
  String? _checkoutError;
  bool _submitting = false;
  bool _checkingPrices = true;

  List<_SellerOrder> _groupBySeller(List<Map<String, dynamic>> items) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final book in items) {
      final sellerId = book['seller_id']?.toString().trim() ?? '';
      final key = sellerId.isNotEmpty
          ? sellerId
          : 'unassigned:${book['id'] ?? book['title'] ?? grouped.length}';
      grouped.putIfAbsent(key, () => []).add(book);
    }
    return grouped.entries
        .map((entry) => _SellerOrder(key: entry.key, books: entry.value))
        .toList();
  }

  int _shippingIndex(String sellerKey) =>
      _selectedShippingBySeller[sellerKey] ?? 0;

  int _shippingTotal(List<_SellerOrder> groups) => groups.fold<int>(
    0,
    (total, group) => total + _shippingOptions[_shippingIndex(group.key)].price,
  );

  void _applyVoucher(List<_SellerOrder> sellerGroups) {
    final code = _voucherController.text.trim().toUpperCase();
    if (sellerGroups.isEmpty) {
      setState(() => _voucherError = 'Add a book before applying a voucher.');
      return;
    }
    setState(
      () => _voucherError = code.isEmpty
          ? 'Enter a voucher code.'
          : 'This voucher is not available right now.',
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMainAddress();
    _refreshCartPrices().whenComplete(() {
      if (mounted) setState(() => _checkingPrices = false);
    });
  }

  /// The cart is persisted locally, so its prices may be stale by checkout.
  /// Replace them with the canonical Supabase listing values before showing a
  /// payable total, and check once more immediately before creating payment.
  Future<bool> _refreshCartPrices({bool requireReviewIfChanged = false}) async {
    final cachedBooks = CartService.instance.items;
    if (cachedBooks.isEmpty) return true;

    try {
      final ids = cachedBooks
          .map((book) => book['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      if (ids.length != cachedBooks.length) {
        throw StateError('A cart item is missing its listing ID.');
      }

      final rows = await Supabase.instance.client
          .from('books')
          .select()
          .inFilter('id', ids);
      final listings = {
        for (final raw in rows as List)
          (raw['id']?.toString() ?? ''): Map<String, dynamic>.from(raw as Map),
      };
      if (listings.length != ids.length) {
        throw StateError('A book in your cart is no longer listed.');
      }

      var changed = false;
      final currentBooks = <Map<String, dynamic>>[];
      for (final cached in cachedBooks) {
        final latest = listings[cached['id']?.toString()];
        if (latest == null ||
            latest['qc_status'] != 'approved' ||
            ((latest['stock'] as num?)?.toInt() ?? 0) < 1) {
          throw StateError(
            '${cached['title'] ?? 'A book'} is no longer available. Remove it from your cart.',
          );
        }
        if (cached['price'] != latest['price'] ||
            cached['seller_id'] != latest['seller_id']) {
          changed = true;
        }
        currentBooks.add({...cached, ...latest});
      }

      if (changed) CartService.instance.replaceAll(currentBooks);
      if (changed && requireReviewIfChanged) {
        if (mounted) {
          setState(() {
            _checkoutError =
                'Harga atau toko buku berubah. Total terbaru sudah ditampilkan; periksa kembali sebelum melanjutkan.';
          });
        }
        return false;
      }
      return true;
    } catch (error) {
      if (mounted) {
        setState(() {
          _checkoutError =
              'Harga/stok terbaru belum dapat diverifikasi: ${error.toString().replaceFirst('Exception: ', '')}';
        });
      }
      return false;
    }
  }

  Future<void> _loadMainAddress() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final metadata = user.userMetadata ?? const <String, dynamic>{};
    var name = (metadata['full_name'] ?? metadata['name'] ?? '').toString();
    var phone = (metadata['phone_number'] ?? metadata['phone'] ?? '')
        .toString();
    var street = (metadata['street'] ?? '').toString();
    var city = (metadata['city'] ?? '').toString();
    var postalCode = (metadata['postal_code'] ?? '').toString();

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('full_name, street, city, postal_code')
          .eq('id', user.id)
          .maybeSingle();
      if (profile != null) {
        name = (profile['full_name'] ?? name).toString();
        street = (profile['street'] ?? street).toString();
        city = (profile['city'] ?? city).toString();
        postalCode = (profile['postal_code'] ?? postalCode).toString();
      }
    } catch (_) {
      // Fall back to the address saved in the user's auth metadata.
    }

    try {
      final userRecord = await Supabase.instance.client
          .from('users')
          .select('phone_number')
          .eq('id', user.id)
          .maybeSingle();
      phone = (userRecord?['phone_number'] ?? phone).toString();
    } catch (_) {
      // Auth metadata remains the fallback for the phone number.
    }

    final hasAddress = [
      street,
      city,
      postalCode,
    ].any((part) => part.trim().isNotEmpty);
    if (!mounted) return;
    setState(() {
      _nameController.text = name;
      _phoneController.text = phone;
      _streetController.text = street;
      _cityController.text = city;
      _postalCodeController.text = postalCode;
      _hasMainAddress = hasAddress;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

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
          final sellerGroups = _groupBySeller(items);
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width < 500
                        ? 16
                        : 24,
                    vertical: 26,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Checkout',
                            style: GoogleFonts.inter(
                              color: _ink,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confirm delivery and payment before placing your order.',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF77716D),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final narrow = constraints.maxWidth < 820;
                              final details = _detailsCard(sellerGroups);
                              final summary = _summaryCard(cart, sellerGroups);
                              if (narrow) {
                                return Column(
                                  children: [
                                    details,
                                    const SizedBox(height: 18),
                                    summary,
                                  ],
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 7, child: details),
                                  const SizedBox(width: 20),
                                  SizedBox(width: 350, child: summary),
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

  Widget _detailsCard(List<_SellerOrder> sellerGroups) => _surface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery & payment',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _sectionLabel('Delivery address')),
            if (_hasMainAddress)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE7DA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Main Address',
                  style: GoogleFonts.inter(
                    color: _orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        _addressForm(),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: _sectionLabel('Shipping by store')),
            Text(
              '${sellerGroups.length} ${sellerGroups.length == 1 ? 'store' : 'stores'}',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF77716D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (sellerGroups.isEmpty)
          Text(
            'Add a book to choose its shipping method.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
          )
        else
          for (var i = 0; i < sellerGroups.length; i++) ...[
            _sellerShippingGroup(sellerGroups[i]),
            if (i != sellerGroups.length - 1) const SizedBox(height: 12),
          ],
        const SizedBox(height: 22),
        _sectionLabel('Payment method'),
        const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 500 ? 12 : 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFCBCBCB)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select payment method',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < _paymentOptions.length; i++) ...[
                _paymentTile(_paymentOptions[i]),
                if (i != _paymentOptions.length - 1) const SizedBox(height: 9),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7F1),
            border: Border.all(color: const Color(0xFFF0D3C2)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline_rounded, color: _orange, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secure payment',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Your selected method will be opened in the secure Midtrans checkout.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.4,
                        color: const Color(0xFF6F6863),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _sellerShippingGroup(_SellerOrder group) => FutureBuilder(
    future: SellerRepository.forBook(group.books.first),
    builder: (context, snapshot) {
      final seller = SellerRepository.displayName(
        group.books.first,
        profile: snapshot.data,
      );
      final city = snapshot.data?['city']?.toString().trim();
      final origin = city == null || city.isEmpty
          ? 'Ships separately from this store'
          : 'Ships from $city';
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF8),
          border: Border.all(color: const Color(0xFFE8D8CD)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront_outlined, color: _orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    seller,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                origin,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF77716D),
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _shippingOptions.length; i++) ...[
              _shippingTile(group.key, i),
              if (i != _shippingOptions.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      );
    },
  );

  Widget _shippingTile(String sellerKey, int index) {
    final option = _shippingOptions[index];
    final selected = _shippingIndex(sellerKey) == index;
    return InkWell(
      onTap: () => setState(() => _selectedShippingBySeller[sellerKey] = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE2D2) : Colors.white,
          border: Border.all(
            color: selected ? _orange : const Color(0xFFCBCBCB),
            width: selected ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(option.icon, color: _orange, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.detail,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF726C67),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              option.price == 0 ? 'Rp 0' : formatRupiah(option.price),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 9),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _orange : const Color(0xFFB7B2AE),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressForm() => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 540;
      final city = _formField(
        'City',
        _cityController,
        hint: 'Enter city',
        textCapitalization: TextCapitalization.words,
      );
      final postalCode = _formField(
        'Postal code',
        _postalCodeController,
        hint: 'Enter postal code',
        keyboardType: TextInputType.number,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasMainAddress) ...[
            Text(
              'Prefilled from your profile. You can edit it for this order.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF77716D),
              ),
            ),
            const SizedBox(height: 12),
          ],
          _formField(
            'Full name',
            _nameController,
            hint: 'Enter recipient name',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          _formField(
            'Phone number',
            _phoneController,
            hint: 'Enter phone number',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _formField(
            'Street address',
            _streetController,
            hint: 'Street name, building, house number',
            minLines: 2,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          if (narrow) ...[
            city,
            const SizedBox(height: 12),
            postalCode,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: city),
                const SizedBox(width: 12),
                Expanded(child: postalCode),
              ],
            ),
        ],
      );
    },
  );

  Widget _formField(
    String label,
    TextEditingController controller, {
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int minLines = 1,
    int maxLines = 1,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 13,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD8C9BE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _orange, width: 1.4),
          ),
        ),
      ),
    ],
  );

  Widget _paymentTile(_PaymentOption option) {
    final selected = _selectedPayment == option.name;
    return InkWell(
      onTap: () => setState(() => _selectedPayment = option.name),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 500 ? 10 : 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE2D2) : Colors.white,
          border: Border.all(
            color: selected ? _orange : const Color(0xFFCBCBCB),
            width: selected ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _orange : const Color(0xFFC4C0BD),
              size: 20,
            ),
            const SizedBox(width: 12),
            Icon(option.icon, color: _orange, size: 23),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF726C67),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(CartService cart, List<_SellerOrder> sellerGroups) {
    final items = sellerGroups.expand((group) => group.books).toList();
    final shippingTotal = _shippingTotal(sellerGroups);
    final originalTotal = cart.subtotal + shippingTotal;
    final amountDue = originalTotal;
    return _surface(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order summary',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < sellerGroups.length; i++) ...[
            _summarySellerHeader(sellerGroups[i]),
            const SizedBox(height: 9),
            for (final book in sellerGroups[i].books) ...[
              _checkoutItem(book),
              const SizedBox(height: 9),
            ],
            _shippingBreakdownRow(sellerGroups[i]),
            if (i != sellerGroups.length - 1) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
            ],
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
          _summaryRow(
            'Subtotal (${items.length} ${items.length == 1 ? 'book' : 'books'})',
            formatRupiah(cart.subtotal),
          ),
          const SizedBox(height: 10),
          _summaryRow('Total shipping', formatRupiah(shippingTotal)),
          const SizedBox(height: 16),
          _voucherSection(sellerGroups),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
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
                formatRupiah(amountDue),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Payment: $_selectedPayment',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF77716D),
            ),
          ),
          if (_checkoutError != null) ...[
            const SizedBox(height: 10),
            Text(
              _checkoutError!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: items.isEmpty || _submitting || _checkingPrices
                  ? null
                  : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE4DED9),
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: Text(
                _checkingPrices
                    ? 'Checking current prices…'
                    : _submitting
                    ? 'Connecting to Midtrans…'
                    : 'Continue to payment',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your secure payment page will open next.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF77716D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summarySellerHeader(_SellerOrder group) => FutureBuilder(
    future: SellerRepository.forBook(group.books.first),
    builder: (context, snapshot) {
      final seller = SellerRepository.displayName(
        group.books.first,
        profile: snapshot.data,
      );
      return Row(
        children: [
          const Icon(Icons.storefront_outlined, color: _orange, size: 17),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              seller,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    },
  );

  Widget _voucherSection(List<_SellerOrder> sellerGroups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _voucherController,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) {
                  if (_voucherError != null) {
                    setState(() => _voucherError = null);
                  }
                },
                onSubmitted: (_) => _applyVoucher(sellerGroups),
                decoration: InputDecoration(
                  hintText: 'Enter voucher code',
                  prefixIcon: const Icon(Icons.local_offer_outlined, size: 19),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD8C9BE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _orange, width: 1.3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: sellerGroups.isEmpty
                  ? null
                  : () => _applyVoucher(sellerGroups),
              style: OutlinedButton.styleFrom(
                foregroundColor: _orange,
                side: const BorderSide(color: _orange),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Apply',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        if (_voucherError != null) ...[
          const SizedBox(height: 6),
          Text(
            _voucherError!,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          'No voucher codes are available right now.',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: const Color(0xFF77716D),
          ),
        ),
      ],
    );
  }

  Widget _shippingBreakdownRow(_SellerOrder group) => FutureBuilder(
    future: SellerRepository.forBook(group.books.first),
    builder: (context, snapshot) {
      final seller = SellerRepository.displayName(
        group.books.first,
        profile: snapshot.data,
      );
      final option = _shippingOptions[_shippingIndex(group.key)];
      return _summaryRow(
        '${option.name} · $seller',
        formatRupiah(option.price),
        small: true,
      );
    },
  );

  Widget _checkoutItem(Map<String, dynamic> book) => Row(
    children: [
      Expanded(
        child: Text(
          book['title']?.toString() ?? 'Untitled book',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(fontSize: 12),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        formatRupiah(book['price']),
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ],
  );

  Widget _summaryRow(String label, String value, {bool small = false}) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: small ? 11 : 14,
            color: small ? const Color(0xFF77716D) : null,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(value, style: GoogleFonts.inter(fontSize: small ? 11 : 14)),
    ],
  );

  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
  }) => Container(
    width: double.infinity,
    padding: padding,
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
    child: child,
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
  );

  String _checkoutErrorText(Object error) {
    try {
      final rawDetails = (error as dynamic).details;
      final dynamic decoded = rawDetails is String
          ? jsonDecode(rawDetails)
          : rawDetails;
      if (decoded is Map) {
        if (decoded['code'] == 'price_changed' && decoded['quote'] is Map) {
          final quote = decoded['quote'] as Map;
          final quotedBooks = quote['books'];
          if (quotedBooks is List) {
            final byId = {
              for (final raw in quotedBooks)
                (raw['id']?.toString() ?? ''): Map<String, dynamic>.from(
                  raw as Map,
                ),
            };
            final refreshed = CartService.instance.items.map((cached) {
              final latest = byId[cached['id']?.toString()];
              return latest == null ? cached : {...cached, ...latest};
            }).toList();
            CartService.instance.replaceAll(refreshed);
          }
          return 'Harga listing berubah saat checkout. Total terbaru sudah ditampilkan; periksa kembali sebelum melanjutkan.';
        }
        if (decoded['error'] != null) return decoded['error'].toString();
      }
    } catch (_) {
      // Fall back to the regular exception message.
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _placeOrder() async {
    if (_submitting) return;
    final requiredFields = [
      _nameController,
      _phoneController,
      _streetController,
      _cityController,
      _postalCodeController,
    ];
    if (requiredFields.any((controller) => controller.text.trim().isEmpty)) {
      setState(() => _checkoutError = 'Please complete all delivery details.');
      return;
    }

    if (CartService.instance.items.isEmpty) {
      setState(
        () => _checkoutError =
            'Your cart is empty. Add an available book before checkout.',
      );
      return;
    }

    setState(() {
      _submitting = true;
      _checkoutError = null;
    });
    try {
      final pricesVerified = await _refreshCartPrices(
        requireReviewIfChanged: true,
      );
      if (!pricesVerified) return;

      final cartItems = CartService.instance.items;
      final groups = _groupBySeller(cartItems);
      if (groups.isEmpty ||
          groups.any((group) => group.key.startsWith('unassigned:'))) {
        setState(
          () => _checkoutError =
              'A book is missing its seller. Refresh your catalog and try again.',
        );
        return;
      }
      final expectedTotal =
          CartService.instance.subtotal + _shippingTotal(groups);

      final response = await Supabase.instance.client.functions.invoke(
        'create-midtrans-transaction',
        body: {
          'book_ids': cartItems.map((book) => book['id']).toList(),
          'expected_gross_amount': expectedTotal,
          'payment_method': _selectedPayment,
          'delivery_address': {
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'street': _streetController.text.trim(),
            'city': _cityController.text.trim(),
            'postal_code': _postalCodeController.text.trim(),
          },
          'shipping_by_seller': {
            for (final group in groups)
              group.key: {
                'method': _shippingOptions[_shippingIndex(group.key)].code,
              },
          },
        },
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final serverGrossAmount = (data['gross_amount'] as num?)?.toInt();
      if (serverGrossAmount == null) {
        throw StateError(
          'Backend checkout belum diperbarui. Jangan lanjutkan pembayaran; deploy Edge Function terbaru terlebih dahulu.',
        );
      }
      if (serverGrossAmount != expectedTotal) {
        throw StateError(
          'Total server ${formatRupiah(serverGrossAmount)} berbeda dari checkout ${formatRupiah(expectedTotal)}. Pembayaran dibatalkan; coba lagi setelah keranjang diperbarui.',
        );
      }
      final paymentUrl = Uri.tryParse(data['redirect_url']?.toString() ?? '');
      if (paymentUrl == null || !paymentUrl.hasScheme) {
        throw Exception('Midtrans did not return a valid payment URL.');
      }
      final opened = await launchUrl(
        paymentUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) throw Exception('Could not open the Midtrans payment page.');
      final paymentOrderId = data['order_id']?.toString();
      if (paymentOrderId == null || paymentOrderId.isEmpty) {
        throw StateError('Midtrans order reference is missing.');
      }
      if (mounted) {
        await Navigator.of(
          context,
        ).pushNamed('/payment-status/${Uri.encodeComponent(paymentOrderId)}');
      }
    } catch (error) {
      if (mounted) setState(() => _checkoutError = _checkoutErrorText(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _ShippingOption {
  final String name;
  final String code;
  final String detail;
  final int price;
  final IconData icon;

  const _ShippingOption({
    required this.name,
    required this.code,
    required this.detail,
    required this.price,
    required this.icon,
  });
}

class _PaymentOption {
  final String name;
  final String detail;
  final IconData icon;

  const _PaymentOption({
    required this.name,
    required this.detail,
    required this.icon,
  });
}

class _SellerOrder {
  final String key;
  final List<Map<String, dynamic>> books;

  const _SellerOrder({required this.key, required this.books});
}
