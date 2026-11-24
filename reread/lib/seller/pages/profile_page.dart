import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reread/services/account_mode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../component/top_bar.dart';

class _OrderHistoryItem {
  final String order;
  final String status;

  const _OrderHistoryItem({required this.order, required this.status});
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color bgColor = const Color(0xFFF1EAE3);
  final Color primaryOrange = const Color(0xFFFF5500);

  final _supabase = Supabase.instance.client;

  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  bool _isLoading = true;
  bool _isEditingAddress = false;
  bool _isSavingAddress = false;

  String _name = '';
  String _shopName = '';
  String _email = '';
  String _phone = '';
  String? _avatarUrl;
  String _ratingText = 'Belum ada ulasan';
  List<_OrderHistoryItem> _recentOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final meta = user.userMetadata ?? {};
      dynamic profileRow;

      try {
        profileRow = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
      } catch (_) {
        try {
          profileRow = await _supabase
              .from('users')
              .select()
              .eq('id', user.id)
              .maybeSingle();
        } catch (_) {}
      }

      String? usersPhone;
      try {
        final userRow = await _supabase
            .from('users')
            .select('phone_number')
            .eq('id', user.id)
            .maybeSingle();
        usersPhone = userRow?['phone_number']?.toString();
      } catch (_) {}

      final historyList = <_OrderHistoryItem>[];
      try {
        final orderItems = await _supabase
            .from('order_items')
            .select(
              'order_id, created_at, orders!inner(id, status, payment_status)',
            )
            .eq('seller_id', user.id)
            .order('created_at', ascending: false)
            .limit(12);

        final seenOrders = <String>{};
        for (final item in List.from(orderItems)) {
          final order = Map<String, dynamic>.from(item['orders'] as Map);
          final rawId = (order['id'] ?? item['order_id'] ?? '').toString();
          if (!seenOrders.add(rawId)) continue;
          final shortId = rawId.length > 8
              ? rawId.substring(0, 8).toUpperCase()
              : rawId;
          historyList.add(
            _OrderHistoryItem(
              order: 'Order #RR-$shortId',
              status: _formatStatus(
                (order['payment_status'] ?? order['status'] ?? 'pending')
                    .toString(),
              ),
            ),
          );
          if (historyList.length == 3) break;
        }
      } catch (_) {}

      final resolvedName =
          (profileRow?['full_name'] ??
                  profileRow?['name'] ??
                  profileRow?['username'] ??
                  meta['full_name'] ??
                  meta['name'] ??
                  meta['username'] ??
                  user.email?.split('@').first ??
                  'Seller')
              .toString();

      final resolvedEmail = (profileRow?['email'] ?? user.email ?? '-')
          .toString();

      final rawPhone =
          usersPhone ??
          profileRow?['phone'] ??
          profileRow?['phone_number'] ??
          meta['phone'] ??
          meta['phone_number'] ??
          user.phone;
      final resolvedPhone = (rawPhone != null && rawPhone.toString().isNotEmpty)
          ? rawPhone.toString()
          : 'No phone number added';

      final resolvedAvatar = (profileRow?['avatar_url'] ?? meta['avatar_url'])
          ?.toString();

      final ratingVal = profileRow?['rating']?.toString();
      final resolvedRating = (ratingVal != null && ratingVal.isNotEmpty)
          ? '$ratingVal - Trusted reader'
          : 'Belum ada ulasan';
      final resolvedShopName =
          (profileRow?['shop_name'] ?? meta['shop_name'] ?? '')
              .toString()
              .trim();

      _streetController.text =
          (profileRow?['street'] ??
                  profileRow?['address'] ??
                  meta['street'] ??
                  meta['address'] ??
                  '')
              .toString();
      _cityController.text = (profileRow?['city'] ?? meta['city'] ?? '')
          .toString();
      _postalCodeController.text =
          (profileRow?['postal_code'] ??
                  profileRow?['zip_code'] ??
                  meta['postal_code'] ??
                  '')
              .toString();

      if (!mounted) return;
      setState(() {
        _name = resolvedName;
        _shopName = resolvedShopName;
        _email = resolvedEmail;
        _phone = resolvedPhone;
        _avatarUrl = resolvedAvatar;
        _ratingText = resolvedRating;
        _recentOrders = historyList;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAddress() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isSavingAddress = true);

    final street = _streetController.text.trim();
    final city = _cityController.text.trim();
    final postalCode = _postalCodeController.text.trim();

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            ...?user.userMetadata,
            'street': street,
            'city': city,
            'postal_code': postalCode,
          },
        ),
      );

      try {
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'full_name': _name,
          'street': street,
          'city': city,
          'postal_code': postalCode,
          if (_avatarUrl != null) 'avatar_url': _avatarUrl,
        }, onConflict: 'id');
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _isEditingAddress = false;
        _isSavingAddress = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Address updated')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSavingAddress = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update address: $e')));
    }
  }

  Future<void> _handleSignOut() async {
    await _supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _changeRoleToBuyer() async {
    try {
      await AccountMode.set('buyer');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not switch to buyer mode: $error')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
      case 'paid':
      case 'to_ship':
        return 'To ship';
      case 'out_for_delivery':
        return 'In transit';
      case 'delivered':
        return 'Delivered';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomTopBar(activePage: 'Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text
            Text(
              'Your profile',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage details, addresses, and transaction access.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF7A7A7A),
              ),
            ),
            const SizedBox(height: 24),

            // Top Section: Profile Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Avatar
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAEDE8),
                      shape: BoxShape.circle,
                      image: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                          ? DecorationImage(
                              image: NetworkImage(_avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                        ? Center(
                            child: Text(
                              _name.isNotEmpty ? _name[0].toUpperCase() : '',
                              style: GoogleFonts.inter(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: primaryOrange,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 32),

                  // Profile Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          _isLoading ? 'Loading...' : _name,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        if (_shopName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _shopName,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF77716D),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : _email,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF555555),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLoading ? '...' : _phone,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF555555),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFF5500),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _ratingText,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF5500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFDDDDDD)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/seller_catalog_page',
                            );
                          },
                          child: Text(
                            'View My catalog',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Profile Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/edit_profile_page');
                      _fetchProfileData();
                    },
                    child: Text(
                      'Edit Profile',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Section: Address & Transaction History
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // My Address Form
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Address',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          'Street',
                          _streetController,
                          hint: 'Enter street address',
                          readOnly: !_isEditingAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'City',
                          _cityController,
                          hint: 'Enter city',
                          readOnly: !_isEditingAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Postal code',
                          _postalCodeController,
                          hint: 'Enter postal code',
                          readOnly: !_isEditingAddress,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _isSavingAddress
                              ? null
                              : () {
                                  if (_isEditingAddress) {
                                    _saveAddress();
                                  } else {
                                    setState(() => _isEditingAddress = true);
                                  }
                                },
                          child: Text(
                            _isSavingAddress
                                ? 'Saving...'
                                : (_isEditingAddress
                                      ? 'Save Address'
                                      : 'Edit Address'),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Transaction History & Account Actions
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Transaction History Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction history',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Seller',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryOrange,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_isLoading)
                              Text(
                                'Loading...',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF555555),
                                ),
                              )
                            else if (_recentOrders.isEmpty)
                              Text(
                                'No transactions yet',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF555555),
                                ),
                              )
                            else
                              ...List.generate(_recentOrders.length, (index) {
                                final item = _recentOrders[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == _recentOrders.length - 1
                                        ? 0
                                        : 12,
                                  ),
                                  child: _buildHistoryItem(
                                    item.order,
                                    item.status,
                                  ),
                                );
                              }),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/transaction_history_page',
                                );
                              },
                              child: Text(
                                'View More',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Account Action Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50000),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: _handleSignOut,
                          child: Text(
                            'Logout',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: _handleSignOut,
                          child: Text(
                            'Switch Account',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C2C2C),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: _changeRoleToBuyer,
                          child: Text(
                            'Change Role to Buyer',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String hint = '',
    bool readOnly = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF555555),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFFAAAAAA),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: primaryOrange),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(String order, String status) {
    return Row(
      children: [
        Flexible(
          child: Text(
            order,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF555555),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '·',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF555555),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          status,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}
