import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../component/top_bar.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);
  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  static const orange = Color(0xFFF95200);
  late Future<List<Map<String, dynamic>>> _orders;
  @override
  void initState() {
    super.initState();
    _orders = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final db = Supabase.instance.client;
    final user = db.auth.currentUser;
    if (user == null) return [];
    final rawItems = await db
        .from('order_items')
        .select(
          'order_id, title, unit_price, created_at, orders!inner(id, status, payment_status, created_at)',
        )
        .eq('seller_id', user.id)
        .order('created_at', ascending: false);
    final grouped = <String, Map<String, dynamic>>{};
    for (final raw in rawItems as List) {
      final item = Map<String, dynamic>.from(raw as Map);
      final orderId = item['order_id'].toString();
      final order = Map<String, dynamic>.from(item['orders'] as Map);
      final row = grouped.putIfAbsent(
        orderId,
        () => {
          'id': orderId,
          'order': order,
          'titles': <String>[],
          'subtotal': 0,
          'created_at': item['created_at'],
        },
      );
      (row['titles'] as List<String>).add((item['title'] ?? 'Buku').toString());
      row['subtotal'] =
          (row['subtotal'] as int) +
          ((item['unit_price'] as num?)?.round() ?? 0);
    }
    if (grouped.isEmpty) return [];
    final shipments = await db
        .from('order_shipments')
        .select(
          'order_id, courier, tracking_number, status, shipped_at, created_at',
        )
        .eq('seller_id', user.id)
        .inFilter('order_id', grouped.keys.toList());
    for (final raw in shipments as List) {
      final shipment = Map<String, dynamic>.from(raw as Map);
      grouped[shipment['order_id'].toString()]?['shipment'] = shipment;
    }
    return grouped.values.toList();
  }

  void _reload() => setState(() => _orders = _load());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF0E5DD),
    appBar: const CustomTopBar(activePage: ''),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _orders,
      builder: (context, snapshot) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Tracking pesanan',
            style: GoogleFonts.inter(
              fontSize: 29,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pantau proses pengiriman pesanan dari katalog Anda.',
            style: GoogleFonts.inter(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          if (snapshot.connectionState == ConnectionState.waiting)
            const Padding(
              padding: EdgeInsets.all(44),
              child: Center(child: CircularProgressIndicator(color: orange)),
            )
          else if (snapshot.hasError)
            _notice(
              'Tracking belum dapat dimuat',
              '${snapshot.error}',
              retry: _reload,
            )
          else if ((snapshot.data ?? []).isEmpty)
            _notice(
              'Belum ada pesanan',
              'Pesanan buyer akan muncul di sini setelah transaksi dibuat.',
            )
          else
            ...snapshot.data!.map(_orderCard),
        ],
      ),
    ),
  );

  Widget _orderCard(Map<String, dynamic> row) {
    final order = Map<String, dynamic>.from(row['order'] as Map);
    final shipment = row['shipment'] == null
        ? null
        : Map<String, dynamic>.from(row['shipment'] as Map);
    final paid = order['payment_status'] == 'paid';
    final delivered = shipment?['status'] == 'delivered';
    final shipped = shipment != null;
    final titles = (row['titles'] as List<String>).join(', ');
    final date = DateTime.tryParse('${row['created_at']}')?.toLocal();
    final dateText = date == null
        ? 'Tanggal tidak tersedia'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, box) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.local_shipping_outlined, color: orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titles,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pesanan ${row['id']} · $dateText',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _rupiah(row['subtotal'] as int),
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _timeline(paid, shipped, delivered),
            const SizedBox(height: 12),
            Text(
              'Status: ${delivered
                  ? 'Terkirim'
                  : shipped
                  ? 'Dalam pengiriman'
                  : paid
                  ? 'Siap dikirim'
                  : (order['payment_status'] ?? 'Menunggu pembayaran')}',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF51443E),
              ),
            ),
            if (shipment != null) ...[
              const SizedBox(height: 8),
              Text(
                '${shipment['courier']} · Resi ${shipment['tracking_number']}',
                style: GoogleFonts.inter(color: Colors.black54),
              ),
            ],
            if (paid && !shipped)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: orange),
                  onPressed: () => _registerShipment(row['id'].toString()),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah resi'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _timeline(bool paid, bool shipped, bool delivered) => Wrap(
    spacing: 0,
    runSpacing: 10,
    children: [
      _step('Pembayaran', paid, Icons.payments_outlined),
      _connector(paid && shipped),
      _step('Dikirim', shipped, Icons.local_shipping_outlined),
      _connector(shipped && delivered),
      _step('Terkirim', delivered, Icons.check_circle_outline),
    ],
  );

  Widget _step(String label, bool complete, IconData icon) => SizedBox(
    width: 142,
    child: Row(
      children: [
        Icon(icon, size: 19, color: complete ? orange : Colors.black26),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: complete ? const Color(0xFF333333) : Colors.black45,
              fontWeight: complete ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    ),
  );
  Widget _connector(bool complete) => SizedBox(
    width: 30,
    height: 22,
    child: Center(
      child: Container(
        height: 2,
        color: complete ? orange : const Color(0xFFE3D8D0),
      ),
    ),
  );

  Future<void> _registerShipment(String orderId) async {
    final courier = TextEditingController();
    final tracking = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Informasi pengiriman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: courier,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Kurir'),
            ),
            TextField(
              controller: tracking,
              decoration: const InputDecoration(labelText: 'Nomor resi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) {
      courier.dispose();
      tracking.dispose();
      return;
    }
    try {
      await Supabase.instance.client.rpc(
        'register_seller_shipment',
        params: {
          'p_order_id': orderId,
          'p_courier': courier.text.trim(),
          'p_tracking_number': tracking.text.trim(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Resi tersimpan. Buyer dapat melihat detail pengiriman.',
            ),
          ),
        );
        _reload();
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan resi: $error')));
    } finally {
      courier.dispose();
      tracking.dispose();
    }
  }

  Widget _notice(String title, String body, {VoidCallback? retry}) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        const SizedBox(height: 7),
        Text(body, style: GoogleFonts.inter(color: Colors.black54)),
        if (retry != null)
          TextButton(onPressed: retry, child: const Text('Coba lagi')),
      ],
    ),
  );
  String _rupiah(int value) =>
      'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
}
