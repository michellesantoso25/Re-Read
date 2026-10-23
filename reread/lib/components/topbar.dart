import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTopBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE05627);

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Main TopBar
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'lib/assets/logo.png',
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: primaryOrange, width: 2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 40),

                  // Main Navigation
                  _navLink('Home', isActive: true),
                  _navLink('New Arrivals'),
                  _navLink('Categories'),
                  _navLink('Sell a Book'),
                  _navLink('Help & Support'),

                  const Spacer(),

                  // Cart Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F1EA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 16, color: Color(0xFF22201F)),
                        const SizedBox(width: 6),
                        Text(
                          'Cart',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Notification Icon
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 20),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),

                  // Profile Avatar
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFD9D9D9),
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Genre
            Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              color: Colors.white,
              child: Row(
                children: [
                  _genreItem('Fiction'),
                  _genreItem('Non-Fiction'),
                  _genreItem('Mystery'),
                  _genreItem('Biography'),
                  _genreItem('Children'),
                  _genreItem('Young Adult'),
                  _genreItem('Comics & Graphic Novels'),
                  _genreItem('Science & Tech'),
                  _genreItem('Romance'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navLink(String title, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive ? const Color(0xFFE05627) : const Color(0xFF555555),
        ),
      ),
    );
  }

  Widget _genreItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF666666)),
      ),
    );
  }
}