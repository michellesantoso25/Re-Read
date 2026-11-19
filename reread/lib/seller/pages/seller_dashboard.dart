import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../component/top_bar.dart';

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({Key? key}) : super(key: key);

  static const Color primaryOrange = Color(0xFFF95200);
  static const Color lightOrangeBar = Color(0xFFFFE1D2);
  static const Color bgColor = Color(0xFFF0E5DD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomTopBar(activePage: 'Dashboard'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          final isTablet = constraints.maxWidth >= 700 && constraints.maxWidth < 1050;
          final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 40.0);

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
                    _buildStatCard('Active users', '12,480', '+8.2%'),
                    _buildStatCard('Live listings', '6,214', '+324'),
                    _buildStatCard('Sales volume', 'Rp 84,2 Jt', '+12.5%'),
                    _buildStatCard('Books recirculated', '18,906', '+1,102'),
                  ],
                ),
                const SizedBox(height: 16),

                // Analytics Chart & Recent Activity
                if (isMobile || isTablet)
                  Column(
                    children: [
                      _buildChartCard(isMobile: isMobile),
                      const SizedBox(height: 16),
                      _buildRecentActivityCard(),
                    ],
                  )
                else
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

  Widget _buildChartCard({bool isMobile = false}) {
    return Container(
      height: isMobile ? 260 : 320,
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
              children: [
                _buildBar(0.3),
                _buildBar(0.4),
                _buildBar(0.35),
                _buildBar(0.6),
                _buildBar(0.45),
                _buildBar(0.7),
                _buildBar(0.55),
                _buildBar(0.95, isPrimary: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, {bool isPrimary = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
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
    );
  }

  Widget _buildRecentActivityCard() {
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
          _buildActivityItem('New seller verified'),
          _buildActivityItem('32 listings approved'),
          _buildActivityItem('Payout batch completed'),
          _buildActivityItem('8 reports need review', isLast: true),
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
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF333333)),
          ),
        ),
        if (!isLast) const Divider(color: Color(0xFFEEEEEE), height: 16),
      ],
    );
  }
}