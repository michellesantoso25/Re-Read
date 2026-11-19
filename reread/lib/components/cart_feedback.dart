import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reread/services/cart_service.dart';

void addBookToCart(BuildContext context, Map<String, dynamic> book) {
  final added = CartService.instance.add(book);
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF302D2B),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        content: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE05627),
              child: Icon(Icons.check_rounded, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    added ? 'Added to your cart' : 'Already in your cart',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    book['title']?.toString() ?? 'Book',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}
