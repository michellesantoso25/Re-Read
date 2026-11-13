import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../component/top_bar.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({Key? key}) : super(key: key);

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
                InkWell(
                  onTap: () {
                    Navigator.pop(context); 
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
                      'Messages',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Talk directly with buyers and sellers.',
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
                //Contacts List Card
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
                          'Contacts',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildContactItem('Nora S. · Online', isActive: true),
                        _buildContactItem('Jon Bell · 12m'),
                        _buildContactItem('Amelia R. · Yesterday'),
                        _buildContactItem('Reader Care · Sep 20'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                //Chat Area Card
                Expanded(
                  flex: 7,
                  child: Container(
                    height: 550,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chat Header
                        Text(
                          'Nora S.',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'About The Midnight Library - Rp 95.000',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Chat Bubble
                        _buildChatBubble('Hi Maya! The copy is clean with only light shelf wear.'),
                        
                        const Spacer(),

                        // Message Input Area
                        Text(
                          'Message',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 44,
                          child: TextField(
                            controller: TextEditingController(text: 'Perfect, thank you. Could you ship tomorrow?'),
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF555555)),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(color: primaryOrange),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Send Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Send message',
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

  Widget _buildContactItem(String text, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFAEDE8) : const Color(0xFFEBE6E0), 
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: const Color(0xFF333333),
          fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  // Widget bubble chat
  Widget _buildChatBubble(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFEBE6E0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4), 
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF333333)),
      ),
    );
  }
}