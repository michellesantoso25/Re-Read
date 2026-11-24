import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reread/components/topbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyerOrderDetailPage extends StatefulWidget {
  final String orderId;
  const BuyerOrderDetailPage({super.key, required this.orderId});

  @override
  State<BuyerOrderDetailPage> createState() => _BuyerOrderDetailPageState();
}

class _BuyerOrderDetailPageState extends State<BuyerOrderDetailPage> {
  static const _orange = Color(0xFFF95200);
  static const _background = Color(0xFFF0E5DD);
  late Future<Map<String, dynamic>?> _order;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _order = _loadOrder();
  }

  Future<Map<String, dynamic>?> _loadOrder() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    final row = await Supabase.instance.client
        .from('orders')
        .select(
          'id, status, payment_status, gross_amount, subtotal, shipping_total, created_at, completed_at, order_items(title, unit_price, seller_id), order_shipments(courier, tracking_number, status, shipped_at, delivered_at), order_issue_reports(id, description, status, created_at)',
        )
        .eq('id', widget.orderId)
        .eq('buyer_id', user.id)
        .maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row);
  }

  void _reload() => setState(() => _order = _loadOrder());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    appBar: const CustomTopBar(activeNav: null),
    body: FutureBuilder<Map<String, dynamic>?>(
      future: _order,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final width = MediaQuery.sizeOf(context).width;
        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: width < 700 ? 16 : 32,
            vertical: 24,
          ),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail pesanan',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF262323),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Lihat status pembayaran dan pengiriman pesanan Anda.',
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
                            'Detail pesanan belum dapat dimuat',
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
                            onPressed: _reload,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    )
                  else if (data == null)
                    _panel(
                      Text(
                        'Pesanan tidak ditemukan atau bukan milik akun ini.',
                        style: GoogleFonts.inter(color: Colors.black54),
                      ),
                    )
                  else
                    _details(data),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  Widget _details(Map<String, dynamic> order) {
    final items = (order['order_items'] as List? ?? []).cast<Map>();
    final shipments = (order['order_shipments'] as List? ?? []).cast<Map>();
    final reports = (order['order_issue_reports'] as List? ?? []).cast<Map>();
    final paid = order['payment_status'] == 'paid';
    final sellerCount = items
        .map((item) => item['seller_id'])
        .where((id) => id != null)
        .toSet()
        .length;
    final shipmentReady =
        shipments.isNotEmpty &&
        sellerCount > 0 &&
        shipments.length >= sellerCount;
    final completed =
        order['status'] == 'delivered' ||
        (shipmentReady &&
            shipments.every((shipment) => shipment['status'] == 'delivered'));
    final hasShipment = shipments.isNotEmpty;
    final amount = (order['gross_amount'] as num?)?.round() ?? 0;
    final created = DateTime.tryParse('${order['created_at']}')?.toLocal();
    final dateLabel = created == null
        ? 'Tanggal tidak tersedia'
        : '${created.day.toString().padLeft(2, '0')}/${created.month.toString().padLeft(2, '0')}/${created.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pesanan #${order['id']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _statusChip(_paymentLabel(order['payment_status'])),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Dibuat $dateLabel',
                style: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
              ),
              const Divider(height: 24),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item['title'] ?? 'Buku'}',
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ),
                      Text(
                        _rupiah((item['unit_price'] as num?)?.round() ?? 0),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total pembayaran',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    _rupiah(amount),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status pengiriman',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _timeline(
                paid,
                hasShipment,
                completed,
                compact: MediaQuery.sizeOf(context).width < 460,
              ),
              const SizedBox(height: 14),
              if (!paid)
                Text(
                  'Pembayaran belum lunas. Pengiriman akan diproses setelah pembayaran berhasil.',
                  style: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
                )
              else if (!hasShipment)
                Text(
                  'Penjual belum memasukkan kurir dan nomor resi.',
                  style: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
                )
              else ...[
                ...shipments.map(
                  (shipment) => Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          color: _orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${shipment['courier'] ?? 'Kurir'}',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Resi: ${shipment['tracking_number'] ?? '-'}',
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                              Text(
                                'Status: ${_shipmentLabel(shipment['status'])}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!shipmentReady)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Pesanan berisi beberapa penjual. Konfirmasi selesai tersedia setelah semua penjual mengirim pesanan.',
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 14),
              Text(
                'Status tracking mengikuti update yang dicatat penjual dan konfirmasi penerimaan Anda.',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Laporan masalah',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (reports.isEmpty)
                Text(
                  'Belum ada laporan untuk pesanan ini.',
                  style: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
                )
              else
                ...reports.map(
                  (report) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6F1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${report['description']}',
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Status laporan: ${_reportLabel(report['status'])}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: !paid || _working ? null : _reportIssue,
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Laporkan masalah'),
                  ),
                  if (completed)
                    FilledButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Pesanan selesai'),
                    )
                  else
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: _orange),
                      onPressed: !paid || !shipmentReady || _working
                          ? null
                          : () => _confirmReceived(order['id'].toString()),
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(_working ? 'Memproses…' : 'Pesanan diterima'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeline(
    bool paid,
    bool shipped,
    bool completed, {
    required bool compact,
  }) => compact
      ? Column(
          children: [
            _timelineRow('Pembayaran', paid, Icons.payments_outlined),
            _timelineRow('Dikirim', shipped, Icons.local_shipping_outlined),
            _timelineRow('Diterima', completed, Icons.check_circle_outline),
          ],
        )
      : Row(
          children: [
            _step('Pembayaran', paid, Icons.payments_outlined),
            _connector(paid && shipped),
            _step('Dikirim', shipped, Icons.local_shipping_outlined),
            _connector(shipped && completed),
            _step('Diterima', completed, Icons.check_circle_outline),
          ],
        );

  Widget _timelineRow(String label, bool done, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: done ? _orange : Colors.black26, size: 20),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: done ? FontWeight.w600 : FontWeight.normal,
            color: done ? const Color(0xFF302D2B) : Colors.black45,
          ),
        ),
      ],
    ),
  );

  Widget _step(String label, bool done, IconData icon) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: done ? _orange : Colors.black26),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: done ? const Color(0xFF302D2B) : Colors.black45,
          ),
        ),
      ],
    ),
  );
  Widget _connector(bool active) => SizedBox(
    width: 24,
    child: Container(
      height: 2,
      color: active ? _orange : const Color(0xFFE4D9D1),
    ),
  );
  Widget _panel(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
  Widget _statusChip(String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFFFEEE5),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      value,
      style: GoogleFonts.inter(
        color: _orange,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Future<void> _confirmReceived(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pesanan sudah diterima?'),
        content: const Text(
          'Konfirmasi hanya jika semua buku dalam pesanan sudah Anda terima.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Belum'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, sudah diterima'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _working = true);
    try {
      await Supabase.instance.client.rpc(
        'confirm_buyer_order_received',
        params: {'p_order_id': orderId},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan ditandai selesai. Terima kasih!'),
        ),
      );
      _reload();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyelesaikan pesanan: $error')),
        );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _reportIssue() async {
    final controller = TextEditingController();
    final description = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporkan masalah'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          maxLength: 2000,
          decoration: const InputDecoration(
            hintText: 'Ceritakan masalah pada pesanan ini (min. 10 karakter).',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kirim laporan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (description == null || !mounted) return;
    if (description.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jelaskan masalah minimal 10 karakter.')),
      );
      return;
    }
    setState(() => _working = true);
    try {
      await Supabase.instance.client.rpc(
        'report_buyer_order_issue',
        params: {'p_order_id': widget.orderId, 'p_description': description},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dikirim.')),
      );
      _reload();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim laporan: $error')),
        );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  String _paymentLabel(dynamic status) => switch ('$status') {
    'paid' => 'Lunas',
    'pending' => 'Menunggu pembayaran',
    'expire' => 'Kedaluwarsa',
    'cancel' => 'Dibatalkan',
    'deny' => 'Ditolak',
    _ => '$status',
  };
  String _shipmentLabel(dynamic status) =>
      status == 'delivered' ? 'Terkirim' : 'Dalam pengiriman';
  String _reportLabel(dynamic status) => switch ('$status') {
    'open' => 'Menunggu ditinjau',
    'reviewing' => 'Sedang ditinjau',
    'resolved' => 'Selesai',
    'closed' => 'Ditutup',
    _ => '$status',
  };
  String _rupiah(int value) =>
      'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
}
