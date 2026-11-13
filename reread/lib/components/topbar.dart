import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reread/pages/buyer_pages/genre_page.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Menu utama yang sedang aktif (berwarna orange). Contoh: 'Home', 'Categories'.
  final String? activeNav;

  /// Genre yang sedang dibuka (berwarna hitam). Null kalau tidak sedang di halaman genre.
  final String? activeGenre;

  const CustomTopBar({Key? key, this.activeNav = 'Home', this.activeGenre})
      : super(key: key);

  // Menu -> route. Menu yang belum punya halaman diisi null (tampil "coming soon").
  static const Map<String, String?> _navRoutes = {
    'Home': '/home',
    'New Arrivals': null,
    'Categories': null,
    'Sell a Book': null,
    'Help & Support': null,
  };

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
                    'lib/assets/logo2.png',
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
                  for (final title in _navRoutes.keys) _navLink(context, title),

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
                  _genreItem(context, 'Fiction'),
                  _genreItem(context, 'Non-Fiction'),
                  _genreItem(context, 'Mystery'),
                  _genreItem(context, 'Biography'),
                  _genreItem(context, 'Children'),
                  _genreItem(context, 'Young Adult'),
                  _genreItem(context, 'Comics & Graphic Novels'),
                  _genreItem(context, 'Science & Tech'),
                  _genreItem(context, 'Romance'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navLink(BuildContext context, String title) {
    final isActive = title == activeNav;
    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          if (isActive && activeGenre == null) return; // sudah di halaman ini
          final route = _navRoutes[title];
          if (route != null) {
            Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title coming soon!'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFFE05627) : const Color(0xFF555555),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _genreItem(BuildContext context, String title) {
    final isActive = title == activeGenre;
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          if (isActive) return; // sudah di genre ini
          final page = PageRouteBuilder(
            pageBuilder: (_, __, ___) => GenrePage(genre: title),
            // Tanpa animasi supaya pindah genre terasa instan
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
          if (activeGenre != null) {
            // Sudah di halaman genre: ganti, jangan ditumpuk
            Navigator.of(context).pushReplacement(page);
          } else {
            Navigator.of(context).push(page);
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : const Color(0xFF666666),
              ),
            ),
          ),
        ),
      ),
    );
  }
}