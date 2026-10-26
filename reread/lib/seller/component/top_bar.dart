import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTopBar({Key? key}) : super(key: key);

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
                    padding: const EdgeInsets.only(bottom: 4.0), // Menyesuaikan tinggi teks dengan logo
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

              //main Navigation
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _navLink('Dashboard', isActive: true),
                        _navLink('Catalog'),
                        _navLink('Sell a Book'),
                        _navLink('Transaction History'),
                      ],
                    ),
                  ),
                ),
              ),

              //Bagian Kanan (Wallet, Notifikasi, Profile)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wallet Balance
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAEDE8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Wallet balance ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF888888),
                          ),
                        ),
                        Text(
                          '\$48.20',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22201F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 24, color: Color(0xFF22201F)),
                    onPressed: () {},
                    splashRadius: 20,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 16),

                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: primaryOrange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _navLink(String title, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), 
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive ? const Color(0xFFFF5500) : const Color(0xFF555555),
        ),
      ),
    );
  }
}