import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../component/top_bar.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  final Color bgColor = const Color(0xFFF1EAE3);
  final Color primaryOrange = const Color(0xFFFF5500);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomTopBar(activePage: ''), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text with Back Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Tombol Back 
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context); 
                    } else {
                      Navigator.pushReplacementNamed(context, '/seller_dashboard');
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFDDDDDD)),
                    ),
                    child: const Icon(Icons.arrow_back, color: Color(0xFF2C2C2C), size: 20),
                  ),
                ),
                const SizedBox(width: 20),
                
                // Title & Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sale #RR-2071',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage fulfillment and book verification.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF7A7A7A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Main Content Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Seller/Buyer Info Card
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seller',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Buyer',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: primaryOrange),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Seller',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: primaryOrange),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildOrderItem('The Midnight Library · Delivered'),
                        _buildOrderItem('Circe · In transit'),
                        _buildOrderItem('Klara and the Sun · Processing'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                //Status Timeline Card
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status timeline',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Timeline Items
                        _buildTimelineItem('Order confirmed', isCompleted: true),
                        _buildTimelineItem('Book verification: Approved', isCompleted: true),
                        _buildTimelineItem('Shipped by seller', isCompleted: true),
                        _buildTimelineItem('Out for delivery', isCompleted: false),
                        
                        const SizedBox(height: 8),
                        
                        // Fulfillment Status
                        Text(
                          'Fulfillment status: Awaiting carrier scan',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Message Buyer Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/messages_page');
                          },
                          child: Text(
                            'Message buyer',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  Widget _buildOrderItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EAE3), 
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String text, {bool isCompleted = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFFF5500) : const Color(0xFFD6CFC9),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}