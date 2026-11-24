import 'package:flutter/material.dart';
import 'package:reread/pages/buyer_pages/profile_page.dart' as buyer_profile;
import 'package:reread/services/account_mode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The single profile URL renders the profile appropriate to the active account.
class ProfileRoutePage extends StatelessWidget {
  const ProfileRoutePage({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: AccountMode.shouldOpenSellerProfile(
      Supabase.instance.client.auth.currentUser,
    ),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return buyer_profile.ProfilePage(isSellerMode: snapshot.data == true);
    },
  );
}
