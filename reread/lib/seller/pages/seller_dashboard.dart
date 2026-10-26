import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../component/top_bar.dart'; // Pastikan path import sesuai

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({Key? key}) : super(key: key);

  final Color primaryOrange = const Color(0xFFFF5500);
  final Color bgColor = const Color(0xFFF1EAE3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text
            Text(
              'Marketplace overview',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Wednesday, 24 September - live platform performance',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF7A7A7A),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons Row
            Row(
              children: [
                Expanded(child: _buildActionCard(Icons.add_circle_outline, 'Sell A Book')),
                const SizedBox(width: 16),
                Expanded(child: _buildActionCard(Icons.history, 'Transaction History')),
                const SizedBox(width: 16),
                Expanded(child: _buildActionCard(Icons.local_shipping_outlined, 'Order Tracking')),
              ],
            ),
            const SizedBox(height: 16),

            // Stats Row
            Row(
              children: [
                Expanded(child: _buildStatCard('Active users', '12,480', '+8.2%')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Live listings', '6,214', '+324')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Sales volume', '\$84.2K', '+12.5%')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Books recirculated', '18,906', '+1,102')),
              ],
            ),
            const SizedBox(height: 16),

            // Bottom Section (Charts & Recent Activity)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart Section
                Expanded(
                  flex: 7,
                  child: Container(
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
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Recent Activity Section
                Expanded(
                  flex: 3,
                  child: Container(
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
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 24),
                        _buildActivityItem('New seller verified'),
                        _buildActivityItem('32 listings approved'),
                        _buildActivityItem('Payout batch completed'),
                        _buildActivityItem('8 reports need review', isLast: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: primaryOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
    );
  }

  Widget _buildStatCard(String title, String value, String increase) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(color: const Color(0xFF7A7A7A), fontSize: 13)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '$increase this month',
            style: GoogleFonts.inter(color: const Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, {bool isPrimary = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: 50,
          height: constraints.maxHeight * heightFactor,
          decoration: BoxDecoration(
            color: isPrimary ? primaryOrange : const Color(0xFFFDE4D8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        );
      }
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