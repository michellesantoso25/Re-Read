import 'package:supabase_flutter/supabase_flutter.dart';

/// Looks up a seller's public shop profile without exposing private profile
/// rows to other marketplace users.
class SellerRepository {
  SellerRepository._();

  static final Map<String, Future<Map<String, dynamic>?>> _sellerRequests = {};

  static Future<Map<String, dynamic>?> forBook(Map<String, dynamic> book) {
    final sellerId = book['seller_id']?.toString().trim() ?? '';
    if (sellerId.isEmpty) return Future.value(null);
    return _sellerRequests.putIfAbsent(sellerId, () => _fetch(sellerId));
  }

  static String displayName(
    Map<String, dynamic> book, {
    Map<String, dynamic>? profile,
  }) {
    final shopName = profile?['shop_name']?.toString().trim();
    if (shopName != null && shopName.isNotEmpty) return shopName;

    final profileName = profile?['full_name']?.toString().trim();
    if (profileName != null && profileName.isNotEmpty) return profileName;

    final savedName = book['seller_name']?.toString().trim();
    if (savedName != null && savedName.isNotEmpty) return savedName;

    final sellerId = book['seller_id']?.toString().trim() ?? '';
    if (sellerId.isEmpty) return 'Independent seller';
    final idSuffix = sellerId.substring(
      0,
      sellerId.length < 8 ? sellerId.length : 8,
    );
    return 'Seller $idSuffix';
  }

  static Future<Map<String, dynamic>?> _fetch(String sellerId) async {
    try {
      final result = await Supabase.instance.client.rpc(
        'get_public_seller_profiles',
        params: {
          'p_seller_ids': [sellerId],
        },
      );
      if (result is List && result.isNotEmpty) {
        return Map<String, dynamic>.from(result.first as Map);
      }
    } catch (_) {
      // Keep listings usable if the public seller profile migration is pending.
    }
    return null;
  }
}
