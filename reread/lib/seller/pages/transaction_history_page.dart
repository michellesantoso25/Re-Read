import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../component/top_bar.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  final Color bgColor = const Color(0xFFF1EAE3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomTopBar(activePage: 'Transaction History'), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction history',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track purchases and get help when needed.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF7A7A7A),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCard(
                    title: 'Transaction verification',
                    centerTitle: true,
                    children: [
                      _buildListItem('The Midnight Library', 'Approved', const Color(0xFF1CB454)),
                      _buildListItem('Circe', 'Pending', const Color(0xFF888888)),
                      _buildListItem('Klara and the Sun', 'Rejected', const Color(0xFFE52E2E)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildCard(
                    title: 'To Shipped',
                    centerTitle: true,
                    children: [
                      _buildListItem('The Midnight Library', 'Ship', const Color(0xFFFF5500)),
                      _buildListItem('Circe', 'Ship', const Color(0xFFFF5500)),
                      _buildListItem('Klara and the Sun', 'Ship', const Color(0xFFFF5500)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildCard(
                    title: 'Out for Delivery',
                    centerTitle: true,
                    children: [
                      _buildListItem('The Midnight Library', 'Check', const Color(0xFFFF5500)),
                      _buildListItem('Circe', 'Check', const Color(0xFFFF5500)),
                      _buildListItem('Klara and the Sun', 'Check', const Color(0xFFFF5500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildCard(
                    title: 'Delivered',
                    centerTitle: true,
                    children: [
                      _buildListItem('The Midnight Library', 'Done', const Color(0xFF27784A)), 
                      _buildListItem('Circe', 'Done', const Color(0xFF27784A)),
                      _buildListItem('Klara and the Sun', 'Done', const Color(0xFF27784A)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                
                Expanded(
                  flex: 2,
                  child: _buildSellerTransactionCard(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
    bool centerTitle = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
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
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSellerTransactionCard() {
    return Container(
      padding: const EdgeInsets.all(28),
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
          const SizedBox(height: 24),
          Text(
            'Seller tab visibly available',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF888888)),
          ),
          const SizedBox(height: 24),
          Text(
            'Tomorrow, and Tomorrow, and Tomorrow · Shipped',
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF333333)),
          ),
          const SizedBox(height: 24),
          Text(
            'Book Verification: Approved',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1CB454)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
               backgroundColor: const Color(0xFFFF5500),
               elevation: 0,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            onPressed: () {},
            child: Text(
              'Report Issue',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: const Color(0xFFFF5500),
        shadows: [
          Shadow(
            color: const Color(0xFFFF5500).withOpacity(0.4),
            blurRadius: 16.0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String bookName, String badgeText, Color badgeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            bookName,
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF333333)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}