import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../component/top_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

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
            // Header Text
            Text(
              'Your profile',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage details, addresses, and transaction access.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF7A7A7A),
              ),
            ),
            const SizedBox(height: 24),

            // Top Section: Profile Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Avatar Placeholder
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAEDE8), 
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 32),
                  
                  // Profile Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Maya Chen',
                          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'maya.chen@email.com',
                          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF555555)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '+1 415 555 0192',
                          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF555555)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFF5500), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '4.9 - Trusted reader',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFFF5500)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFDDDDDD)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: () {},
                          child: Text(
                            'View My catalog',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Profile Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit_profile_page');
                    },
                    child: Text(
                      'Edit Profile',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Section: Address & Transaction History
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //My Address Form (Lebar Flex 2)
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
                          'My Address',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField('Street', '1842 Paper Mill Lane'),
                        const SizedBox(height: 16),
                        _buildTextField('City', 'Oakland'),
                        const SizedBox(height: 16),
                        _buildTextField('Postal code', '94612'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Edit Address',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                //Transaction History & Account Actions (Lebar Flex 1)
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Transaction History Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction history',
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Seller',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: primaryOrange),
                            ),
                            const SizedBox(height: 12),
                            _buildHistoryItem('Order #RR-2048', 'Delivered'),
                            const SizedBox(height: 12),
                            _buildHistoryItem('Order #RR-2019', 'In transit'),
                            const SizedBox(height: 12),
                            _buildHistoryItem('Sale #RR-1982', 'Completed'),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              onPressed: () {},
                              child: Text(
                                'View More',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Account Action Buttons (Logout & Switch Account)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50000), 
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Logout',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Switch Account',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF2C2C2C)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40, 
          child: TextField(
            controller: TextEditingController(text: value),
            readOnly: true,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF555555)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: primaryOrange),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(String order, String status) {
    return Row(
      children: [
        Text(
          order,
          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF555555)),
        ),
        const SizedBox(width: 4),
        Text(
          '·',
          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF555555)),
        ),
        const SizedBox(width: 4),
        Text(
          status,
          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF555555)),
        ),
      ],
    );
  }
}