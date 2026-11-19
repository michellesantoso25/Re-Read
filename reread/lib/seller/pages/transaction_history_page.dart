import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../component/top_bar.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  static const Color bgColor = Color(0xFFF0E5DD);
  static const Color primaryOrange = Color(0xFFF95200);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomTopBar(activePage: 'Transaction History'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 750;
          final isTablet = constraints.maxWidth >= 750 && constraints.maxWidth < 1100;
          final padding = isMobile ? 16.0 : (isTablet ? 24.0 : 40.0);

          final verificationCard = _buildCard(
            title: 'Transaction verification',
            centerTitle: true,
            children: [
              _buildListItem('The Midnight Library', 'Approved', const Color(0xFF1CB454)),
              _buildListItem('Circe', 'Pending', const Color(0xFF888888)),
              _buildListItem('Klara and the Sun', 'Rejected', const Color(0xFFE52E2E)),
            ],
          );

          final toShippedCard = _buildCard(
            title: 'To Shipped',
            centerTitle: true,
            children: [
              _buildListItem('The Midnight Library', 'Ship', primaryOrange),
              _buildListItem('Circe', 'Ship', primaryOrange),
              _buildListItem('Klara and the Sun', 'Ship', primaryOrange),
            ],
          );

          final deliveryCard = _buildCard(
            title: 'Out for Delivery',
            centerTitle: true,
            children: [
              _buildListItem('The Midnight Library', 'Check', primaryOrange),
              _buildListItem('Circe', 'Check', primaryOrange),
              _buildListItem('Klara and the Sun', 'Check', primaryOrange),
            ],
          );

          final deliveredCard = _buildCard(
            title: 'Delivered',
            centerTitle: true,
            children: [
              _buildListItem('The Midnight Library', 'Done', const Color(0xFF27784A)),
              _buildListItem('Circe', 'Done', const Color(0xFF27784A)),
              _buildListItem('Klara and the Sun', 'Done', const Color(0xFF27784A)),
            ],
          );

          final sellerTransactionCard = _buildSellerTransactionCard();

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction history',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track purchases and get help when needed.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF7A7A7A),
                  ),
                ),
                const SizedBox(height: 24),

                if (isMobile) ...[
                  verificationCard,
                  const SizedBox(height: 16),
                  toShippedCard,
                  const SizedBox(height: 16),
                  deliveryCard,
                  const SizedBox(height: 16),
                  deliveredCard,
                  const SizedBox(height: 16),
                  sellerTransactionCard,
                ] else if (isTablet) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: verificationCard),
                      const SizedBox(width: 16),
                      Expanded(child: toShippedCard),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: deliveryCard),
                      const SizedBox(width: 16),
                      Expanded(child: deliveredCard),
                    ],
                  ),
                  const SizedBox(height: 16),
                  sellerTransactionCard,
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: verificationCard),
                      const SizedBox(width: 24),
                      Expanded(child: toShippedCard),
                      const SizedBox(width: 24),
                      Expanded(child: deliveryCard),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: deliveredCard),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: sellerTransactionCard),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
    bool centerTitle = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          _buildGlowTitle(title),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSellerTransactionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlowTitle('Seller Transaction'),
          const SizedBox(height: 20),
          Text(
            'Seller tab visibly available',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF888888)),
          ),
          const SizedBox(height: 18),
          Text(
            'Tomorrow, and Tomorrow, and Tomorrow · Shipped',
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF333333)),
          ),
          const SizedBox(height: 18),
          Text(
            'Book Verification: Approved',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1CB454),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: () {},
            child: Text(
              'Report Issue',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: primaryOrange,
        shadows: [
          Shadow(
            color: primaryOrange.withOpacity(0.35),
            blurRadius: 14.0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String bookName, String badgeText, Color badgeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              bookName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF333333)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}