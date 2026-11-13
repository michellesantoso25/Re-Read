import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String activePage;

  const CustomTopBar({
    Key? key,
    this.activePage = 'Dashboard',
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF5500);

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Row(
            children: [
              // Logo
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'lib/assets/logo.png',
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: primaryOrange, size: 32);
                    },
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'for seller',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),

              // Navigation Menu
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _navLink(context, 'Dashboard', isActive: activePage == 'Dashboard', route: '/seller_dashboard'),
                        _navLink(context, 'Catalog', isActive: activePage == 'Catalog', route: '/seller_catalog_page'),
                        _navLink(context, 'Sell a Book', isActive: activePage == 'Sell a Book', route: '/sell_a_book_page'),
                        _navLink(context, 'Transaction History', isActive: activePage == 'Transaction History', route: '/transaction_history_page'),
                      ],
                    ),
                  ),
                ),
              ),

              // Right Section
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAEDE8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text('Wallet balance ', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF888888))),
                        Text('Rp 48.200', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF22201F))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Notification
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 24, color: Color(0xFF22201F)),
                    onPressed: () {
                      if (activePage != 'Notifications') {
                        Navigator.pushNamed(context, '/notifications_page');
                      }
                    },
                    splashRadius: 20,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 16),

                  // Profile
                  InkWell(
                    onTap: () {
                      if (activePage != 'Profile') {
                        Navigator.pushNamed(context, '/profile_page');
                      }
                    },
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: primaryOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLink(BuildContext context, String title, {bool isActive = false, required String route}) {
    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xFFFF5500) : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}