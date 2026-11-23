import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../component/top_bar.dart';

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({Key? key}) : super(key: key);

  static const Color primaryOrange = Color(0xFFF95200);
  static const Color bgColor = Color(0xFFF0E5DD);
  SupabaseClient get _db => Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomTopBar(activePage: 'Dashboard'),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadOverview(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          return LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 700;
              final padding = mobile ? 16.0 : 36.0;
              return SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: GoogleFonts.inter(
                        fontSize: mobile ? 23 : 29,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Ringkasan toko berdasarkan aktivitas akun Anda.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF77716D),
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: primaryOrange,
                          ),
                        ),
                      )
                    else if (snapshot.hasError) ...[
                      _messageCard(
                        'Data toko belum dapat dimuat',
                        'Detail: ${snapshot.error}\nPastikan migration Supabase sudah diterapkan dan akses seller aktif.',
                        onRetry: () => Navigator.pushReplacementNamed(
                          context,
                          '/seller_dashboard',
                        ),
                      ),
                    ] else if (data == null)
                      _messageCard(
                        'Silakan masuk sebagai seller',
                        'Masuk untuk melihat ringkasan toko Anda.',
                      )
                    else ...[
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          _statCard(
                            'Buku terdaftar',
                            '${data['books']}',
                            Icons.menu_book_outlined,
                            mobile,
                          ),
                          _statCard(
                            'Transaksi dibayar',
                            '${data['sales']}',
                            Icons.receipt_long_outlined,
                            mobile,
                          ),
                          _statCard(
                            'Pendapatan tercatat',
                            _rupiah(data['balance'] as int),
                            Icons.account_balance_wallet_outlined,
                            mobile,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Aksi cepat',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _action(
                            context,
                            Icons.add_circle_outline,
                            'Jual buku',
                            '/sell_a_book_page',
                          ),
                          _action(
                            context,
                            Icons.inventory_2_outlined,
                            'Katalog saya',
                            '/seller_catalog_page',
                          ),
                          _action(
                            context,
                            Icons.history,
                            'Riwayat transaksi',
                            '/transaction_history_page',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _loadOverview() async {
    final user = _db.auth.currentUser;
    if (user == null) return null;
    final results = await Future.wait([
      _db.from('books').select('id').eq('seller_id', user.id),
      _db
          .from('seller_wallet_ledger')
          .select('amount')
          .eq('seller_id', user.id),
    ]);
    final ledger = results[1] as List;
    final balance = ledger.fold<int>(
      0,
      (sum, row) => sum + ((row['amount'] as num?)?.round() ?? 0),
    );
    return {
      'books': (results[0] as List).length,
      'sales': ledger.length,
      'balance': balance,
    };
  }

  String _rupiah(int value) =>
      'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
  Widget _statCard(String title, String value, IconData icon, bool mobile) =>
      SizedBox(
        width: mobile ? double.infinity : 260,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: primaryOrange, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  Widget _action(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) => SizedBox(
    width: 210,
    child: OutlinedButton.icon(
      onPressed: () => Navigator.pushNamed(context, route),
      icon: Icon(icon, color: primaryOrange),
      label: Text(title, style: const TextStyle(color: Color(0xFF333333))),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
  Widget _messageCard(
    String title,
    String description, {
    VoidCallback? onRetry,
  }) => Container(
    width: double.infinity,
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
        Text(description, style: GoogleFonts.inter(color: Colors.black54)),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
      ],
    ),
  );
}
