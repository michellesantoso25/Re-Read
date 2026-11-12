import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../component/top_bar.dart'; 

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  final Color bgColor = const Color(0xFFF1EAE3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomTopBar(activePage: 'Notifications'), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text
            Text(
              'Notifications',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Updates about your books, orders, and community.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF7A7A7A),
              ),
            ),
            const SizedBox(height: 32),

            // Notification List
            _buildNotificationCard(
              title: 'Sale confirmed',
              description: 'Your copy of Circe sold to Amelia R.',
              time: '2 min ago',
              isUnread: true,
            ),
            _buildNotificationCard(
              title: 'Book verified',
              description: 'The Midnight Library passed verification.',
              time: '1 hour ago',
              isUnread: true,
            ),
            _buildNotificationCard(
              title: 'New message',
              description: 'Jon asked about Klara and the Sun.',
              time: 'Yesterday',
              isUnread: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String description,
    required String time,
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(top: 6, right: 16),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5500),
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(width: 24),

          // Main Content (Title & Description)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF7A7A7A),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),

          // Time / Timestamp
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF999999), 
            ),
          ),
        ],
      ),
    );
  }
}