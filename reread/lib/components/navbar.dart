import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNavbar({super.key});

  static const _links = ['Browse', 'Sell', 'About', 'Search'];

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final shortestSide = MediaQuery.sizeOf(context).shortestSide;
      final phone =
          constraints.maxWidth <= 640 ||
          (constraints.maxWidth <= 900 && shortestSide < 600);
      final tablet = !phone && constraints.maxWidth <= 900;
      return Container(
        color: const Color(0xFF1E1E1E),
        padding: EdgeInsets.symmetric(
          horizontal: phone ? 16 : (tablet ? 20 : 32),
          vertical: 10,
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              if (phone)
                Text(
                  'Re:Read',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                Row(
                  children: [
                    for (var i = 0; i < _links.length; i++) ...[
                      TextButton(
                        onPressed: () => _showComingSoon(context, _links[i]),
                        child: Text(
                          _links[i],
                          style: TextStyle(
                            color: i == 0 ? Colors.white : Colors.white70,
                            fontWeight: i == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (i < _links.length - 1)
                        SizedBox(width: tablet ? 0 : 8),
                    ],
                  ],
                ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE05627),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(
                    horizontal: phone ? 15 : 20,
                    vertical: 10,
                  ),
                ),
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Log in'),
              ),
              if (phone) ...[
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Buka menu',
                  onSelected: (label) => _showComingSoon(context, label),
                  itemBuilder: (context) => _links
                      .map(
                        (label) => PopupMenuItem<String>(
                          value: label,
                          child: Text(label),
                        ),
                      )
                      .toList(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title segera tersedia.')));
  }
}
