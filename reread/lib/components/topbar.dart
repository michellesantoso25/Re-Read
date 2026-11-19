import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reread/main.dart';
import 'package:reread/services/cart_service.dart';

import 'package:reread/pages/buyer_pages/categories_page.dart';
import 'package:reread/pages/buyer_pages/cart_page.dart';
import 'package:reread/pages/buyer_pages/genre_page.dart';
import 'package:reread/pages/buyer_pages/home_page.dart';
import 'package:reread/pages/buyer_pages/new_arrivals_page.dart';
import 'package:reread/pages/buyer_pages/profile_page.dart';
import 'package:reread/pages/buyer_pages/sell_book_page.dart';


class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? activeNav;
  final String? activeGenre;

  const CustomTopBar({super.key, this.activeNav = 'Home', this.activeGenre});

  static const Map<String, String?> _navRoutes = {
    'Home': '/home',
    'New Arrivals': '/newArrivals',
    'Categories': '/categories',
    'Sell a Book': '/sellBook',
    'Help & Support': 'null',
  };

  static const Map<String, IconData> _navIcons = {
    'Home': Icons.home_outlined,
    'New Arrivals': Icons.auto_stories_outlined,
    'Categories': Icons.category_outlined,
    'Sell a Book': Icons.sell_outlined,
    'Help & Support': Icons.help_outline_rounded,
  };

  static const _genres = [
    'Fiction',
    'Non-Fiction',
    'Mystery',
    'Biography',
    'Children',
    'Young Adult',
    'Comics & Graphic Novels',
    'Science & Tech',
    'Romance',
  ];

  static const _orange = Color(0xFFE05627);

  @override
  Size get preferredSize => const Size.fromHeight(92);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 200 || constraints.maxHeight < 92) {
          return const SizedBox.shrink();
        }

        final shortestSide = MediaQuery.sizeOf(context).shortestSide;
        final phone =
            constraints.maxWidth <= 640 ||
            (constraints.maxWidth <= 900 && shortestSide < 600);
        final tablet = !phone && constraints.maxWidth <= 1000;
        final horizontalPadding = phone ? 12.0 : (tablet ? 10.0 : 32.0);
        final mobileMenuItems = _navRoutes.keys.toList();
        return Material(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 52,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: phone ? 112 : (tablet ? 96 : null),
                        child: Image.asset(
                          'lib/assets/logo2.png',
                          height: tablet ? 28 : 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.menu_book_rounded,
                                color: _orange,
                                size: 30,
                              ),
                        ),
                      ),
                      if (phone) ...[
                        const Spacer(),
                        _cartButton(
                          context,
                          iconOnly: constraints.maxWidth < 380,
                        ),
                        const SizedBox(width: 2),
                        IconButton(
                          tooltip: 'Notifications',
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            size: 21,
                          ),
                          onPressed: () =>
                              _showComingSoon(context, 'Notification'),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 34,
                            minHeight: 40,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _openProfile(context),
                          borderRadius: BorderRadius.circular(24),
                          child: _profileAvatar(radius: 15),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          tooltip: 'Open menu',
                          padding: EdgeInsets.zero,
                          offset: const Offset(0, 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 4,
                          color: Colors.white,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F3EF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE9E0DA),
                              ),
                            ),
                            child: const Center(
                              child: _HamburgerGlyph(color: Color(0xFF514842)),
                            ),
                          ),
                          onSelected: (title) => _navigate(context, title),
                          itemBuilder: (context) => [
                            ...mobileMenuItems.map(
                              (title) => PopupMenuItem<String>(
                                value: title,
                                height: 46,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: title == activeNav
                                            ? const Color(0xFFFAEEE7)
                                            : const Color(0xFFF6F2EE),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Icon(
                                        _navIcons[title],
                                        size: 17,
                                        color: title == activeNav
                                            ? _orange
                                            : const Color(0xFF615B57),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: title == activeNav
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: const Color(0xFF302D2B),
                                        ),
                                      ),
                                    ),
                                    if (title == activeNav)
                                      const Icon(
                                        Icons.check_rounded,
                                        color: _orange,
                                        size: 18,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        SizedBox(width: tablet ? 10 : 24),
                        for (final title in _navRoutes.keys)
                          _navLink(context, title, tablet: tablet),
                        const Spacer(),
                        _cartButton(
                          context,
                          iconOnly: tablet && constraints.maxWidth < 700,
                        ),
                        SizedBox(width: tablet ? 3 : 14),
                        IconButton(
                          tooltip: 'Notification',
                          icon: const Icon(Icons.notifications_none, size: 20),
                          onPressed: () =>
                              _showComingSoon(context, 'Notification'),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 40,
                          ),
                        ),
                        SizedBox(width: tablet ? 3 : 12),
                        InkWell(
                          onTap: () => _openProfile(context),
                          borderRadius: BorderRadius.circular(24),
                          child: _profileAvatar(radius: 16),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final genre in _genres) _genreItem(context, genre),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _profileAvatar({required double radius}) {
    final avatarUrl = supabase.auth.currentUser?.userMetadata?['avatar_url']
        ?.toString();
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFD9D9D9),
      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
          ? NetworkImage(avatarUrl)
          : null,
      child: avatarUrl == null || avatarUrl.isEmpty
          ? Icon(Icons.person, size: radius + 2, color: Colors.white)
          : null,
    );
  }

  Widget _cartButton(BuildContext context, {bool iconOnly = false}) =>
      AnimatedBuilder(
        animation: CartService.instance,
        builder: (context, _) => Container(
          padding: EdgeInsets.symmetric(
            horizontal: iconOnly ? 8 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F1EA),
            borderRadius: BorderRadius.circular(iconOnly ? 13 : 20),
          ),
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              PageRouteBuilder<void>(
                pageBuilder: (_, _, _) => const CartPage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 16),
                if (!iconOnly) ...[
                  const SizedBox(width: 6),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        'Cart',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (CartService.instance.itemCount > 0)
                        Positioned(
                          top: -7,
                          right: -21,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: const BoxDecoration(
                              color: _orange,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              CartService.instance.itemCount > 99
                                  ? '99+'
                                  : '${CartService.instance.itemCount}',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );

  Widget _navLink(BuildContext context, String title, {required bool tablet}) {
    final isActive = title == activeNav;
    return Padding(
      padding: EdgeInsets.only(right: tablet ? 8 : 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => _navigate(context, title),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            maxLines: 1,
            softWrap: false,
            style: GoogleFonts.inter(
              fontSize: tablet ? 11.5 : 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? _orange : const Color(0xFF555555),
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String title) {
    if (title == activeNav && activeGenre == null) return;
    if (title == 'Categories') {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const CategoriesPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
        (route) => false,
      );
      return;
    }
    if (title == 'New Arrivals') {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const NewArrivalsPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
        (route) => false,
      );
      return;
    }
    if (title == 'Home') {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const HomePage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
        (route) => false,
      );
      return;
    }
    if (title == 'Sell a Book') {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const SellBookPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
        (route) => false,
      );
      return;
    }
    final route = _navRoutes[title];
    if (route != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    } else {
      _showComingSoon(context, title);
    }
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const ProfilePage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title is coming soon.')));
  }

  Widget _genreItem(BuildContext context, String title) {
    final isActive = title == activeGenre;
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          if (isActive) return;
          final page = PageRouteBuilder(
            pageBuilder: (_, _, _) => GenrePage(genre: title),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
          if (activeGenre != null) {
            Navigator.of(context).pushReplacement(page);
          } else {
            Navigator.of(context).push(page);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
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
    );
  }
}

class _HamburgerGlyph extends StatelessWidget {
  final Color color;

  const _HamburgerGlyph({required this.color});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _line(16),
      const SizedBox(height: 4),
      _line(11),
      const SizedBox(height: 4),
      _line(16),
    ],
  );

  Widget _line(double width) => Container(
    width: width,
    height: 1.8,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}
