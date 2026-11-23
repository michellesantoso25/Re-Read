import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../component/top_bar.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);
  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  static const Color bgColor = Color(0xFFF0E5DD);
  static const Color primaryOrange = Color(0xFFF95200);
  late Future<List<Map<String, dynamic>>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];
    final rows = await Supabase.instance.client
        .from('order_items')
        .select(
          'order_id, title, unit_price, created_at, orders!inner(id, status, payment_status, gross_amount, created_at)',
        )
        .eq('seller_id', user.id)
        .order('created_at', ascending: false);
    final grouped = <String, Map<String, dynamic>>{};
    for (final raw in rows as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['order_id'].toString();
      final order = Map<String, dynamic>.from(row['orders'] as Map);
      final existing = grouped.putIfAbsent(
        id,
        () => {
          'id': id,
          'order': order,
          'titles': <String>[],
          'subtotal': 0,
          'created_at': row['created_at'],
        },
      );
      (existing['titles'] as List<String>).add(
        (row['title'] ?? 'Buku').toString(),
      );
      existing['subtotal'] =
          (existing['subtotal'] as int) +
          ((row['unit_price'] as num?)?.round() ?? 0);
    }
    if (grouped.isEmpty) return [];
    final shipmentRows = await Supabase.instance.client
        .from('order_shipments')
        .select('order_id, courier, tracking_number, status, shipped_at')
        .eq('seller_id', user.id)
        .inFilter('order_id', grouped.keys.toList());
    for (final raw in shipmentRows as List) {
      final shipment = Map<String, dynamic>.from(raw as Map);
      grouped[shipment['order_id'].toString()]?['shipment'] = shipment;
    }
    return grouped.values.toList();
  }

  void _reload() {
    setState(() {
      _orders = _load();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: bgColor,
    appBar: const CustomTopBar(activePage: 'Transaction History'),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _orders,
      builder: (context, snapshot) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Riwayat transaksi',
            style: GoogleFonts.inter(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pesanan buku dari katalog Anda.',
            style: GoogleFonts.inter(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          if (snapshot.connectionState == ConnectionState.waiting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: primaryOrange),
              ),
            )
          else if (snapshot.hasError)
            _empty(
              'Riwayat belum dapat dimuat',
              'Periksa migration dan kebijakan akses database.',
            )
          else if ((snapshot.data ?? []).isEmpty)
            _empty(
              'Belum ada transaksi',
              'Pesanan buku Anda akan muncul di sini setelah buyer membuat pesanan.',
            )
          else
            ...snapshot.data!.map(_transactionCard),
        ],
      ),
    ),
  );

  Widget _empty(String title, String body) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(body, style: GoogleFonts.inter(color: Colors.black54)),
      ],
    ),
  );

  Widget _transactionCard(Map<String, dynamic> row) {
    final order = Map<String, dynamic>.from(row['order'] as Map);
    final shipment = row['shipment'] == null
        ? null
        : Map<String, dynamic>.from(row['shipment'] as Map);
    final status = (order['payment_status'] ?? order['status'] ?? 'pending')
        .toString();
    final date = DateTime.tryParse('${row['created_at']}')?.toLocal();
    final dateText = date == null
        ? 'Tanggal tidak tersedia'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final titles = (row['titles'] as List<String>).join(', ');
    final amount = row['subtotal'] as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, color: primaryOrange),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titles,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dateText · ${status.toUpperCase()}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _rupiah(amount),
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Subtotal buku',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (shipment != null) ...[
            const Divider(height: 24),
            Text(
              'Dikirim via ${shipment['courier']} · Resi ${shipment['tracking_number']}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Status: ${shipment['status']}',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
            ),
          ] else if (status == 'paid') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _registerShipment(row['id'].toString()),
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('Input resi pengiriman'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _registerShipment(String orderId) async {
    final courier = TextEditingController();
    final tracking = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi pengiriman'),
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
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result != true || !mounted) {
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
          const SnackBar(content: Text('Informasi pengiriman tersimpan.')),
        );
        _reload();
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan pengiriman: $error')),
        );
    } finally {
      courier.dispose();
      tracking.dispose();
    }
  }

  String _rupiah(int value) =>
      'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
}
