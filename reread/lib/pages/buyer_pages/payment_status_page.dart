import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reread/components/book_card.dart';
import 'package:reread/services/cart_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentStatusPage extends StatefulWidget {
  const PaymentStatusPage({super.key, required this.orderId});

  /// Midtrans order_id, used only as a lookup key. The buyer id is also checked.
  final String orderId;

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  static const _orange = Color(0xFFE94E0B);
  Timer? _pollTimer;
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _items = [];
  String? _error;
  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _refresh());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  String get _paymentStatus =>
      (_order?['payment_status'] ?? _order?['status'] ?? 'pending')
          .toString()
          .toLowerCase();

  bool get _terminal => const {
    'paid',
    'expire',
    'expired',
    'cancel',
    'cancelled',
    'deny',
    'denied',
    'failure',
    'failed',
  }.contains(_paymentStatus);

  Future<void> _refresh() async {
    if (_refreshing || widget.orderId.trim().isEmpty) return;
    _refreshing = true;
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) {
        throw StateError('Silakan masuk kembali untuk melihat status pesanan.');
      }

      final row = await client
          .from('orders')
          .select(
            'id, midtrans_order_id, status, payment_status, gross_amount, created_at',
          )
          .eq('midtrans_order_id', widget.orderId)
          .eq('buyer_id', user.id)
          .maybeSingle();
      if (row == null) {
        throw StateError('Pesanan tidak ditemukan pada akun ini.');
      }

      final order = Map<String, dynamic>.from(row);
      final itemRows = await client
          .from('order_items')
          .select('book_id, title, unit_price')
          .eq('order_id', order['id']);
      final items = (itemRows as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      if (!mounted) return;
      setState(() {
        _order = order;
        _items = items;
        _error = null;
        _loading = false;
      });

      final status = (order['payment_status'] ?? order['status'] ?? 'pending')
          .toString()
          .toLowerCase();
      if (status == 'paid' && items.isNotEmpty) {
        CartService.instance.removeByIds(
          items.map((item) => item['book_id'].toString()).toSet(),
        );
      }
      if (_terminal) _pollTimer?.cancel();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    } finally {
      _refreshing = false;
    }
  }

  ({String title, String message, IconData icon, Color color})
  get _presentation {
    switch (_paymentStatus) {
      case 'paid':
        return (
          title: 'Pembayaran berhasil',
          message:
              'Pembayaran terkonfirmasi. Pesanan sedang diproses oleh seller.',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF00A884),
        );
      case 'expire':
      case 'expired':
        return (
          title: 'Pembayaran kedaluwarsa',
          message:
              'Batas waktu pembayaran sudah berakhir. Silakan buat pesanan baru.',
          icon: Icons.timer_off_rounded,
          color: const Color(0xFFC84A3A),
        );
      case 'cancel':
      case 'cancelled':
        return (
          title: 'Pembayaran dibatalkan',
          message: 'Pesanan ini dibatalkan dan stok telah dikembalikan.',
          icon: Icons.cancel_rounded,
          color: const Color(0xFFC84A3A),
        );
      case 'deny':
      case 'denied':
      case 'failure':
      case 'failed':
        return (
          title: 'Pembayaran belum berhasil',
          message:
              'Midtrans tidak menyelesaikan pembayaran ini. Coba checkout kembali.',
          icon: Icons.error_rounded,
          color: const Color(0xFFC84A3A),
        );
      default:
        return (
          title: 'Menunggu pembayaran',
          message:
              'Selesaikan pembayaran di Midtrans. Status akan diperbarui otomatis setelah notifikasi pembayaran diterima.',
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFFE6A100),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentation = _presentation;
    final total = (_order?['gross_amount'] as num?)?.round() ?? 0;
    return Scaffold(
      backgroundColor: const Color(0xFFF3EAE3),
      appBar: AppBar(
        title: const Text('Status pembayaran'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF302D2B),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      presentation.icon,
                      size: 64,
                      color: presentation.color,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _loading ? 'Memeriksa pembayaran…' : presentation.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error ?? presentation.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba lagi'),
                      ),
                    ],
                    if (_loading && _order == null) ...[
                      const SizedBox(height: 18),
                      const Center(
                        child: CircularProgressIndicator(color: _orange),
                      ),
                    ],
                    if (_order != null) ...[
                      if (!_terminal) ...[
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(color: _orange),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Perbarui status'),
                        ),
                      ],
                      const Divider(height: 32),
                      _detail('Nomor pesanan', widget.orderId),
                      const SizedBox(height: 10),
                      _detail('Total pembayaran', formatRupiah(total)),
                      const SizedBox(height: 10),
                      _detail('Status', _paymentStatus.toUpperCase()),
                      if (_items.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text(
                          'Pesanan',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        for (final item in _items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['title']?.toString() ?? 'Buku',
                                  ),
                                ),
                                Text(formatRupiah(item['unit_price'])),
                              ],
                            ),
                          ),
                      ],
                    ],
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/profile',
                        (route) => false,
                      ),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Lihat riwayat transaksi'),
                      style: FilledButton.styleFrom(backgroundColor: _orange),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      ),
                      child: const Text('Lanjut belanja'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(label, style: GoogleFonts.inter(color: Colors.black54)),
      ),
      const SizedBox(width: 16),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
