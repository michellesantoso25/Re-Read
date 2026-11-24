import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reread/components/topbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyerTransactionHistoryPage extends StatefulWidget {
  const BuyerTransactionHistoryPage({super.key});

  @override
  State<BuyerTransactionHistoryPage> createState() =>
      _BuyerTransactionHistoryPageState();
}

class _BuyerTransactionHistoryPageState
    extends State<BuyerTransactionHistoryPage> {
  static const _orange = Color(0xFFF95200);
  static const _background = Color(0xFFF0E5DD);
  late Future<List<Map<String, dynamic>>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = _loadOrders();
  }

  Future<List<Map<String, dynamic>>> _loadOrders() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];
    final rows = await Supabase.instance.client
        .from('orders')
        .select(
          'id, status, payment_status, gross_amount, created_at, order_items(title, unit_price), order_shipments(courier, tracking_number, status)',
        )
        .eq('buyer_id', user.id)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    appBar: const CustomTopBar(activeNav: null),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _orders,
      builder: (context, snapshot) => LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 700 ? 16 : 32,
            vertical: 24,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction history',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF262323),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Pilih pesanan untuk melihat status pengiriman dan tindakan lanjutan.',
                      style: GoogleFonts.inter(color: Colors.black54),
                    ),
                    const SizedBox(height: 18),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(36),
                          child: CircularProgressIndicator(color: _orange),
                        ),
                      )
                    else if (snapshot.hasError)
                      _panel(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Riwayat transaksi belum dapat dimuat',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: GoogleFonts.inter(color: Colors.black54),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  setState(() => _orders = _loadOrders()),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      )
                    else if ((snapshot.data ?? []).isEmpty)
                      _panel(
                        Text(
                          'Belum ada transaksi.',
                          style: GoogleFonts.inter(color: Colors.black54),
                        ),
                      )
                    else
                      ...snapshot.data!.map(_orderCard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _orderCard(Map<String, dynamic> order) {
    final items = (order['order_items'] as List? ?? []).cast<Map>();
    final shipments = (order['order_shipments'] as List? ?? []).cast<Map>();
    final title = items.isEmpty
        ? 'Pesanan buku'
        : '${items.first['title'] ?? 'Buku'}${items.length > 1 ? ' + ${items.length - 1} lainnya' : ''}';
    final status = (order['payment_status'] ?? order['status'] ?? 'pending')
        .toString();
    final amount = (order['gross_amount'] as num?)?.round() ?? 0;
    final date = DateTime.tryParse('${order['created_at']}')?.toLocal();
    final dateText = date == null
        ? 'Tanggal tidak tersedia'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pushNamed(
            context,
            '/buyer_order_detail',
            arguments: order['id'].toString(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 440;
                final description = Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$dateText · ${_statusLabel(status)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      if (shipments.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          '${shipments.length} pengiriman · ${shipments.map((shipment) => _shipmentLabel(shipment['status'])).toSet().join(', ')}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: _orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
                final price = Text(
                  _rupiah(amount),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF292522),
                  ),
                );
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: _orange,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 13),
                    description,
                    if (compact) ...[
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          price,
                          const SizedBox(height: 5),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: _orange,
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          price,
                          const SizedBox(height: 5),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: _orange,
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
  String _rupiah(int value) =>
      'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

  String _statusLabel(String value) => switch (value.toLowerCase()) {
    'paid' => 'Lunas',
    'pending' => 'Menunggu pembayaran',
    'expire' => 'Kedaluwarsa',
    'cancel' => 'Dibatalkan',
    'deny' => 'Ditolak',
    'delivered' => 'Selesai',
    _ => value,
  };

  String _shipmentLabel(dynamic value) =>
      value == 'delivered' ? 'Terkirim' : 'Dalam pengiriman';
}
