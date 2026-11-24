import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../component/top_bar.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({Key? key}) : super(key: key);
  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  static const orange = Color(0xFFF95200);
  static const background = Color(0xFFF0E5DD);
  late Future<Map<String, dynamic>> _overview;
  SupabaseClient get _db => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _overview = _loadOverview();
  }

  Future<Map<String, dynamic>> _loadOverview() async {
    final user = _db.auth.currentUser;
    if (user == null) throw StateError('Silakan masuk sebagai seller.');
    final data = await Future.wait([
      _db
          .from('books')
          .select('id, title, qc_status, created_at, stock')
          .eq('seller_id', user.id)
          .order('created_at', ascending: false),
      _db
          .from('seller_wallet_ledger')
          .select('amount, order_id, created_at, released_at')
          .eq('seller_id', user.id)
          .order('created_at', ascending: false),
    ]);
    final books = (data[0] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final ledger = (data[1] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final availableLedger = ledger
        .where((row) => row['released_at'] != null)
        .toList();
    final sales = availableLedger.fold<int>(
      0,
      (sum, row) => sum + ((row['amount'] as num?)?.round() ?? 0),
    );
    final pendingSales = ledger
        .where((row) => row['released_at'] == null)
        .fold<int>(
          0,
          (sum, row) => sum + ((row['amount'] as num?)?.round() ?? 0),
        );
    final paidOrders = ledger
        .map((e) => e['order_id'])
        .where((e) => e != null)
        .toSet()
        .length;
    final activeBooks = books
        .where(
          (b) =>
              b['qc_status'] == 'approved' &&
              ((b['stock'] as num?)?.toInt() ?? 0) > 0,
        )
        .length;
    final now = DateTime.now();
    final monthly = List<int>.filled(8, 0);
    for (final row in availableLedger) {
      final date = DateTime.tryParse('${row['released_at']}')?.toLocal();
      if (date == null) continue;
      final ago = (now.year - date.year) * 12 + now.month - date.month;
      if (ago >= 0 && ago < monthly.length)
        monthly[monthly.length - 1 - ago] +=
            (row['amount'] as num?)?.round() ?? 0;
    }
    final activity =
        <Map<String, dynamic>>[
          ...books
              .take(5)
              .map(
                (book) => {
                  'title': (book['title'] ?? 'Listing buku').toString(),
                  'detail': 'Listing · ${_listingStatus(book['qc_status'])}',
                  'created_at': book['created_at'],
                },
              ),
          ...ledger
              .take(5)
              .map(
                (row) => {
                  'title': row['released_at'] == null
                      ? 'Pembayaran diterima · saldo ditahan'
                      : 'Saldo dilepas ke wallet',
                  'detail': _rupiah((row['amount'] as num?)?.round() ?? 0),
                  'created_at': row['created_at'],
                },
              ),
        ]..sort(
          (a, b) => (DateTime.tryParse('${b['created_at']}') ?? DateTime(1970))
              .compareTo(
                DateTime.tryParse('${a['created_at']}') ?? DateTime(1970),
              ),
        );
    return {
      'books': books.length,
      'active': activeBooks,
      'orders': paidOrders,
      'sales': sales,
      'pendingSales': pendingSales,
      'monthly': monthly,
      'activity': activity.take(6).toList(),
    };
  }

  String _listingStatus(dynamic status) => switch ('$status') {
    'approved' => 'Disetujui',
    'rejected' => 'Ditolak',
    'pending_review' => 'Menunggu review',
    _ => 'Draft',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    appBar: const CustomTopBar(activePage: 'Dashboard'),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _overview,
      builder: (context, snapshot) => LayoutBuilder(
        builder: (context, box) {
          final narrow = box.maxWidth < 760;
          final pad = narrow ? 18.0 : 32.0;
          return RefreshIndicator(
            onRefresh: () async => setState(() => _overview = _loadOverview()),
            child: ListView(
              padding: EdgeInsets.all(pad),
              children: [
                Text(
                  'Dashboard toko',
                  style: GoogleFonts.inter(
                    fontSize: narrow ? 27 : 34,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ringkasan katalog dan penjualan Anda · ${_dateLabel(DateTime.now())}',
                  style: GoogleFonts.inter(color: const Color(0xFF77716D)),
                ),
                const SizedBox(height: 22),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(42),
                    child: Center(
                      child: CircularProgressIndicator(color: orange),
                    ),
                  )
                else if (snapshot.hasError)
                  _panel(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data toko belum dapat dimuat',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: GoogleFonts.inter(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => _overview = _loadOverview()),
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  )
                else if (snapshot.hasData) ...[
                  _quickActions(context, narrow),
                  const SizedBox(height: 16),
                  _metricsGrid(snapshot.data!, narrow),
                  const SizedBox(height: 16),
                  if (narrow) ...[
                    _salesPanel(snapshot.data!, narrow),
                    const SizedBox(height: 16),
                    _activityPanel(snapshot.data!),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: _salesPanel(snapshot.data!, narrow),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: _activityPanel(snapshot.data!),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          );
        },
      ),
    ),
  );

  Widget _quickActions(BuildContext context, bool narrow) {
    final items = [
      ('Jual buku', Icons.add_circle_outline, '/sell_a_book_page'),
      ('Riwayat transaksi', Icons.history, '/transaction_history_page'),
      (
        'Tracking pesanan',
        Icons.local_shipping_outlined,
        '/order_tracking_page',
      ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final width = (box.maxWidth - (narrow ? 0 : 28)) / (narrow ? 1 : 3);
        return Wrap(
          spacing: 14,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, item.$3),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: narrow ? 82 : 136,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: orange.withValues(alpha: 0.13),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: narrow
                          ? Row(
                              children: [
                                _actionIcon(item.$2, compact: true),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    item.$1,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _actionIcon(item.$2),
                                const SizedBox(height: 12),
                                Text(
                                  item.$1,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _actionIcon(IconData icon, {bool compact = false}) => Container(
    width: compact ? 46 : 58,
    height: compact ? 46 : 58,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.16),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
    ),
    child: Icon(icon, color: Colors.white, size: compact ? 24 : 30),
  );

  Widget _metricsGrid(Map<String, dynamic> data, bool narrow) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = narrow ? 1 : (constraints.maxWidth >= 1080 ? 4 : 2);
      const gap = 14.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          _metric(
            'Listing aktif',
            '${data['active']}',
            'Dari ${data['books']} buku di katalog',
            Icons.menu_book_outlined,
            width,
          ),
          _metric(
            'Transaksi dibayar',
            '${data['orders']}',
            'Pesanan yang tercatat lunas',
            Icons.receipt_long_outlined,
            width,
          ),
          _metric(
            'Saldo tersedia',
            _rupiah(data['sales'] as int),
            'Saldo yang sudah masuk wallet',
            Icons.account_balance_wallet_outlined,
            width,
          ),
          _metric(
            'Saldo ditahan',
            _rupiah(data['pendingSales'] as int),
            'Dilepas saat buyer konfirmasi atau 14 hari setelah resi',
            Icons.lock_clock_outlined,
            width,
          ),
        ],
      );
    },
  );

  Widget _metric(
    String title,
    String value,
    String caption,
    IconData icon,
    double width,
  ) => SizedBox(
    width: width,
    child: _panel(
      SizedBox(
        height: 154,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: orange, size: 21),
            ),
            const SizedBox(height: 13),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: const Color(0xFF77716D),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 23,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF292522),
              ),
            ),
            const Spacer(),
            Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: const Color(0xFF77716D),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _salesPanel(Map<String, dynamic> data, bool narrow) {
    final values = (data['monthly'] as List<int>);
    final max = values.fold<int>(0, (a, b) => a > b ? a : b);
    final months = List.generate(8, (i) {
      final d = DateTime(DateTime.now().year, DateTime.now().month - 7 + i);
      return _month(d.month);
    });
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pendapatan per bulan',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Saldo tersedia yang sudah dilepas ke wallet',
            style: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                values.length,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: max == 0
                                  ? 0.025
                                  : (values[i] / max)
                                        .clamp(0.04, 1.0)
                                        .toDouble(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: i == values.length - 1
                                      ? orange
                                      : const Color(0xFFFFE0D1),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          months[i],
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (max == 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Belum ada pendapatan pada periode ini.',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  Widget _activityPanel(Map<String, dynamic> data) {
    final activity = data['activity'] as List;
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktivitas terbaru',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (activity.isEmpty)
            Text(
              'Belum ada aktivitas katalog atau transaksi.',
              style: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
            )
          else
            ...activity.map((raw) {
              final row = raw as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row['title'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            row['detail'].toString(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _panel(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFF3EAE4)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A332317),
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
  String _dateLabel(DateTime d) => '${d.day} ${_month(d.month)} ${d.year}';
  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ][month - 1];
  String _rupiah(int value) =>
      'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
}
