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
  static const Color primaryOrange = Color(0xFFF95200);
  static const Color lightOrangeBar = Color(0xFFFFE1D2);
  static const Color bgColor = Color(0xFFF0E5DD);

  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  int _activeBuyers = 0;
  int _activeBuyersThisMonth = 0;
  int _liveListings = 0;
  int _liveListingsThisMonth = 0;
  double _salesVolume = 0;
  double _salesVolumeThisMonth = 0;
  int _booksRecirculated = 0;
  int _booksRecirculatedThisMonth = 0;

  List<String> _monthLabels = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'];
  List<double> _monthlyTotals = [0, 0, 0, 0, 0, 0, 0, 0];
  List<String> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final booksRes = await _supabase
          .from('books')
          .select('id, title, price, created_at')
          .eq('seller_id', user.id)
          .order('created_at', ascending: false);
      final books = List.from(booksRes);

      final ordersRes = await _supabase
          .from('orders')
          .select('id, book_id, buyer_id, price, status, created_at')
          .eq('seller_id', user.id)
          .order('created_at', ascending: false);
      final orders = List.from(ordersRes);

      final Map bookTitles = {};
      for (final b in books) {
        bookTitles[b['id']] = b['title']?.toString() ?? 'Untitled Book';
      }

      final now = DateTime.now();

      int listingsThisMonth = 0;
      for (final b in books) {
        final dt = DateTime.tryParse(b['created_at']?.toString() ?? '');
        if (dt != null && dt.year == now.year && dt.month == now.month) {
          listingsThisMonth++;
        }
      }

      double totalSales = 0;
      double salesThisMonth = 0;
      int recirculated = 0;
      int recirculatedThisMonth = 0;
      final Set uniqueBuyers = {};
      final Set uniqueBuyersThisMonth = {};

      final List<DateTime> last8Months = List.generate(
        8,
        (i) => DateTime(now.year, now.month - (7 - i), 1),
      );
      const shortMonths = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final labels = last8Months.map((d) => shortMonths[d.month - 1]).toList();
      final totals = List<double>.filled(8, 0.0);

      for (final o in orders) {
        final status = (o['status'] ?? '').toString().toLowerCase();
        if (status == 'rejected') continue;

        final price = (o['price'] as num?)?.toDouble() ?? 0.0;
        final dt = DateTime.tryParse(o['created_at']?.toString() ?? '');
        final buyerId = o['buyer_id'];

        totalSales += price;
        if (buyerId != null) uniqueBuyers.add(buyerId);
        if (status == 'delivered') recirculated++;

        if (dt != null) {
          if (dt.year == now.year && dt.month == now.month) {
            salesThisMonth += price;
            if (buyerId != null) uniqueBuyersThisMonth.add(buyerId);
            if (status == 'delivered') recirculatedThisMonth++;
          }

          for (int i = 0; i < last8Months.length; i++) {
            if (dt.year == last8Months[i].year && dt.month == last8Months[i].month) {
              totals[i] += price;
              break;
            }
          }
        }
      }

      final List<String> activities = [];
      for (final o in orders.take(4)) {
        final title = bookTitles[o['book_id']] ?? 'Book #${o['book_id']}';
        final statusLabel = _formatStatusLabel((o['status'] ?? 'pending').toString());
        activities.add('$title · $statusLabel');
      }
      if (activities.length < 4) {
        for (final b in books.take(4 - activities.length)) {
          activities.add('Listed ${b['title']}');
        }
      }

      if (!mounted) return;
      setState(() {
        _activeBuyers = uniqueBuyers.length;
        _activeBuyersThisMonth = uniqueBuyersThisMonth.length;
        _liveListings = books.length;
        _liveListingsThisMonth = listingsThisMonth;
        _salesVolume = totalSales;
        _salesVolumeThisMonth = salesThisMonth;
        _booksRecirculated = recirculated;
        _booksRecirculatedThisMonth = recirculatedThisMonth;
        _monthLabels = labels;
        _monthlyTotals = totals;
        _recentActivities = activities;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
      case 'to_ship':
        return 'To Ship';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  String _formatRupiah(double amount) {
    if (amount <= 0) return 'Rp 0';
    if (amount >= 1000000) {
      final jt = (amount / 1000000).toStringAsFixed(1).replaceAll('.', ',');
      return 'Rp $jt Jt';
    }
    if (amount >= 1000) {
      final rb = (amount / 1000).round();
      return 'Rp $rb rb';
    }
    return 'Rp ${amount.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomTopBar(activePage: 'Dashboard'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final padding = isMobile ? 16.0 : 40.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marketplace overview',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Live platform performance & seller summary',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF7A7A7A),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                if (isMobile)
                  Column(
                    children: [
                      _buildActionCard(context, Icons.add_circle_outline, 'Sell A Book', '/sell_a_book_page', isMobile: true),
                      const SizedBox(height: 12),
                      _buildActionCard(context, Icons.history, 'Transaction History', '/transaction_history_page', isMobile: true),
                      const SizedBox(height: 12),
                      _buildActionCard(context, Icons.local_shipping_outlined, 'Order Tracking', '/order_tracking_page', isMobile: true),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: _buildActionCard(context, Icons.add_circle_outline, 'Sell A Book', '/sell_a_book_page')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildActionCard(context, Icons.history, 'Transaction History', '/transaction_history_page')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildActionCard(context, Icons.local_shipping_outlined, 'Order Tracking', '/order_tracking_page')),
                    ],
                  ),
                const SizedBox(height: 16),

                // Stats Section
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isMobile ? 2 : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isMobile ? 1.45 : 1.75,
                  children: [
                    _buildStatCard('Active buyers', _isLoading ? '...' : '$_activeBuyers', '+$_activeBuyersThisMonth'),
                    _buildStatCard('Live listings', _isLoading ? '...' : '$_liveListings', '+$_liveListingsThisMonth'),
                    _buildStatCard('Sales volume', _isLoading ? '...' : _formatRupiah(_salesVolume), '+${_formatRupiah(_salesVolumeThisMonth)}'),
                    _buildStatCard('Books recirculated', _isLoading ? '...' : '$_booksRecirculated', '+$_booksRecirculatedThisMonth'),
                  ],
                ),
                const SizedBox(height: 16),

                // Analytics Chart & Recent Activity (sejajar kiri-kanan)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: _buildChartCard()),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: _buildRecentActivityCard()),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String route, {
    bool isMobile = false,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: isMobile ? 76 : 120,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: primaryOrange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isMobile
            ? Row(
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 14),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String increase) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: GoogleFonts.inter(color: const Color(0xFF7A7A7A), fontSize: 12)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 6),
          Text(
            '$increase this month',
            style: GoogleFonts.inter(color: const Color(0xFF4CAF50), fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    double maxTotal = 0;
    for (final v in _monthlyTotals) {
      if (v > maxTotal) maxTotal = v;
    }

    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales analytics',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_monthlyTotals.length, (index) {
                final val = _monthlyTotals[index];
                final factor = maxTotal > 0
                    ? (val / maxTotal * 0.95).clamp(0.15, 0.95)
                    : 0.15;
                final isLast = index == _monthlyTotals.length - 1;

                return _buildBar(
                  factor,
                  tooltip: '${_monthLabels[index]}: ${_formatRupiah(val)}',
                  isPrimary: isLast,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, {required String tooltip, bool isPrimary = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Tooltip(
          message: tooltip,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: constraints.maxHeight * heightFactor,
                decoration: BoxDecoration(
                  color: isPrimary ? primaryOrange : lightOrangeBar,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    final items = _recentActivities.isEmpty
        ? ['No recent activity yet']
        : _recentActivities;

    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent activity',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ...List.generate(items.length, (i) {
            return _buildActivityItem(items[i], isLast: i == items.length - 1);
          }),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF333333)),
          ),
        ),
        if (!isLast) const Divider(color: Color(0xFFEEEEEE), height: 16),
      ],
    );
  }
}