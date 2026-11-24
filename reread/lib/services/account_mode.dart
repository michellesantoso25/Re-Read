import 'package:supabase_flutter/supabase_flutter.dart';

class AccountMode {
  AccountMode._();

  static bool isSeller(User? user) {
    final metadata = user?.userMetadata ?? const <String, dynamic>{};
    final modes = [
      metadata['account_type'],
      metadata['role'],
    ].map((value) => value?.toString().trim().toLowerCase() ?? '');
    return modes.any((mode) => mode == 'seller' || mode == 'merchant');
  }

  static Future<bool> shouldOpenSellerProfile(User? user) async {
    if (user == null) return false;
    if (isSeller(user)) return true;

    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final modes = [metadata['account_type'], metadata['role']]
        .map((value) => value?.toString().trim().toLowerCase() ?? '')
        .where((mode) => mode.isNotEmpty)
        .toList();
    if (modes.contains('buyer')) return false;

    final client = Supabase.instance.client;
    try {
      final profile = await client
          .from('profiles')
          .select('shop_name')
          .eq('id', user.id)
          .maybeSingle();
      if ((profile?['shop_name']?.toString().trim().isNotEmpty ?? false)) {
        return true;
      }
    } catch (_) {
      // Older accounts may not have a profile row yet.
    }

    try {
      final listings = await client
          .from('books')
          .select('id')
          .eq('seller_id', user.id)
          .limit(1);
      return (listings as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<void> set(String mode) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    await client.auth.updateUser(
      UserAttributes(
        data: {...?user.userMetadata, 'account_type': mode, 'role': mode},
      ),
    );
  }
}
