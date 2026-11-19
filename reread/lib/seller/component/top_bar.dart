import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reread/main.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String activePage;

  const CustomTopBar({
    Key? key,
    this.activePage = 'Dashboard',
  }) : super(key: key);

  static const _primaryOrange = Color(0xFFF95200);

  static const Map<String, String> _navRoutes = {
    'Dashboard': '/seller_dashboard',
    'Catalog': '/seller_catalog_page',
    'Sell a Book': '/sell_a_book_page',
    'Transaction History': '/transaction_history_page',
  };

  static const Map<String, IconData> _navIcons = {
    'Dashboard': Icons.dashboard_outlined,
    'Catalog': Icons.menu_book_outlined,
    'Sell a Book': Icons.add_circle_outline,
    'Transaction History': Icons.history_rounded,
  };

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide = MediaQuery.sizeOf(context).shortestSide;
        final isPhone =
            constraints.maxWidth <= 680 ||
            (constraints.maxWidth <= 900 && shortestSide < 600);
        final isTablet = !isPhone && constraints.maxWidth <= 1050;
        final horizontalPadding = isPhone ? 16.0 : (isTablet ? 20.0 : 40.0);

        return Material(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 64,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                children: [
                  // Logo + Badge "for seller"
                  InkWell(
                    onTap: () {
                      if (activePage != 'Dashboard') {
                        Navigator.pushReplacementNamed(context, '/seller_dashboard');
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset(
                          'lib/assets/logo2.png',
                          height: isPhone ? 26 : 30,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.menu_book_rounded,
                            color: _primaryOrange,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            'for seller',
                            style: GoogleFonts.inter(
                              fontSize: isPhone ? 12 : 13,
                              fontWeight: FontWeight.w700,
                              color: _primaryOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!isPhone) ...[
                    SizedBox(width: isTablet ? 20 : 40),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _navRoutes.entries.map((entry) {
                            return _navLink(
                              context,
                              entry.key,
                              route: entry.value,
                              isActive: activePage == entry.key,
                              isTablet: isTablet,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),

                  // Wallet Balance
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isPhone ? 10 : 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE1D2).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isPhone)
                          Text(
                            'Wallet ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF7A7A7A),
                            ),
                          ),
                        Text(
                          'Rp 48.200',
                          style: GoogleFonts.inter(
                            fontSize: isPhone ? 11 : 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22201F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isPhone ? 6 : 12),

                  // Notification Icon
                  IconButton(
                    tooltip: 'Notifications',
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 22,
                      color: Color(0xFF22201F),
                    ),
                    onPressed: () {
                      if (activePage != 'Notifications') {
                        Navigator.pushNamed(context, '/notifications_page');
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                  ),
                  SizedBox(width: isPhone ? 6 : 10),

                  // Profile Avatar
                  InkWell(
                    onTap: () {
                      if (activePage != 'Profile') {
                        Navigator.pushNamed(context, '/profile_page');
                      }
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: _profileAvatar(radius: isPhone ? 14 : 16),
                  ),

                  // Hamburger Menu (Khusus Mobile)
                  if (isPhone) ...[
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      tooltip: 'Menu',
                      offset: const Offset(0, 10),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onSelected: (title) {
                        final route = _navRoutes[title];
                        if (route != null && title != activePage) {
                          Navigator.pushReplacementNamed(context, route);
                        }
                      },
                      itemBuilder: (context) => _navRoutes.keys.map((title) {
                        final selected = title == activePage;
                        return PopupMenuItem<String>(
                          value: title,
                          child: Row(
                            children: [
                              Icon(
                                _navIcons[title],
                                size: 18,
                                color: selected
                                    ? _primaryOrange
                                    : const Color(0xFF615B57),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                title,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: selected
                                      ? _primaryOrange
                                      : const Color(0xFF302D2B),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E5DD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          size: 20,
                          color: Color(0xFF302D2B),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navLink(
    BuildContext context,
    String title, {
    required String route,
    bool isActive = false,
    bool isTablet = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 10.0 : 16.0,
          vertical: 8.0,
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: isTablet ? 12.5 : 13.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? _primaryOrange : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }

  Widget _profileAvatar({required double radius}) {
    final avatarUrl = supabase.auth.currentUser?.userMetadata?['avatar_url']
        ?.toString();
    return CircleAvatar(
      radius: radius,
      backgroundColor: _primaryOrange,
      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
          ? NetworkImage(avatarUrl)
          : null,
      child: avatarUrl == null || avatarUrl.isEmpty
          ? Icon(Icons.person, size: radius + 2, color: Colors.white)
          : null,
    );
  }
}