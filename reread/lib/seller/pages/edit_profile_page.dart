import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../component/top_bar.dart';

class _OrderHistoryItem {
  final String order;
  final String status;

  const _OrderHistoryItem({
    required this.order,
    required this.status,
  });
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Color bgColor = const Color(0xFFF1EAE3);
  final Color primaryOrange = const Color(0xFFFF5500);

  final _supabase = Supabase.instance.client;

  final _nameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String _initialEmail = '';
  String _initialStreet = '';
  String _initialCity = '';
  String _initialPostalCode = '';

  String? _avatarUrl;
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarName;

  bool _isLoading = true;
  bool _isSavingProfile = false;
  bool _isSavingAddress = false;

  List<_OrderHistoryItem> _recentOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shopNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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

      final historyList = <_OrderHistoryItem>[];
      try {
        final ordersRes = await _supabase
            .from('orders')
            .select('id, status')
            .eq('seller_id', user.id)
            .order('created_at', ascending: false)
            .limit(3);

        for (final o in List.from(ordersRes)) {
          final rawId = (o['id'] ?? '').toString();
          final shortId = rawId.length > 8
              ? rawId.substring(0, 8).toUpperCase()
              : rawId;
          historyList.add(
            _OrderHistoryItem(
              order: 'Order #RR-$shortId',
              status: _formatStatus((o['status'] ?? 'pending').toString()),
            ),
          );
        }
      } catch (_) {}

      final resolvedName = (profileRow?['full_name'] ??
              profileRow?['name'] ??
              profileRow?['username'] ??
              meta['full_name'] ??
              meta['name'] ??
              meta['username'] ??
              user.email?.split('@').first ??
              '')
          .toString();
      final resolvedShopName = (profileRow?['shop_name'] ??
              meta['shop_name'] ??
              '')
          .toString();

      final resolvedEmail =
          (profileRow?['email'] ?? user.email ?? '').toString();

      final rawPhone = profileRow?['phone'] ??
          profileRow?['phone_number'] ??
          meta['phone'] ??
          meta['phone_number'] ??
          user.phone ??
          '';

      final resolvedAvatar =
          (profileRow?['avatar_url'] ?? meta['avatar_url'])?.toString();

      final resolvedStreet = (profileRow?['street'] ??
              profileRow?['address'] ??
              meta['street'] ??
              meta['address'] ??
              '')
          .toString();
      final resolvedCity =
          (profileRow?['city'] ?? meta['city'] ?? '').toString();
      final resolvedPostal = (profileRow?['postal_code'] ??
              profileRow?['zip_code'] ??
              meta['postal_code'] ??
              '')
          .toString();

      _nameController.text = resolvedName;
      _shopNameController.text = resolvedShopName;
      _emailController.text = resolvedEmail;
      _phoneController.text = rawPhone.toString();

      _streetController.text = resolvedStreet;
      _cityController.text = resolvedCity;
      _postalCodeController.text = resolvedPostal;

      _initialEmail = resolvedEmail;
      _initialStreet = resolvedStreet;
      _initialCity = resolvedCity;
      _initialPostalCode = resolvedPostal;

      if (!mounted) return;
      setState(() {
        _avatarUrl = resolvedAvatar;
        _recentOrders = historyList;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedAvatarBytes = bytes;
      _selectedAvatarName = picked.name;
    });
  }

  Future<String?> _uploadAvatarIfNeeded(String userId) async {
    if (_selectedAvatarBytes == null) return _avatarUrl;

    final ext = (_selectedAvatarName ?? 'avatar.jpg').split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';

    try {
      final path = '$userId/$fileName';
      await _supabase.storage.from('avatars').uploadBinary(
            path,
            _selectedAvatarBytes!,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );
      return _supabase.storage.from('avatars').getPublicUrl(path);
    } catch (_) {
      final fallbackPath = 'avatars/$userId/$fileName';
      await _supabase.storage.from('book-covers').uploadBinary(
            fallbackPath,
            _selectedAvatarBytes!,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );
      return _supabase.storage.from('book-covers').getPublicUrl(fallbackPath);
    }
  }

  Future<void> _submitProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final name = _nameController.text.trim();
    final shopName = _shopNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || shopName.length < 2 || shopName.length > 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFE52E2E),
          content: Text('Enter your name, email, and a shop name (2–60 characters).'),
        ),
      );
      return;
    }

    setState(() => _isSavingProfile = true);

    try {
      final uploadedAvatarUrl = await _uploadAvatarIfNeeded(user.id);

      final updatedMeta = <String, dynamic>{
        ...?user.userMetadata,
        'full_name': name,
        'name': name,
        'shop_name': shopName,
        'phone': phone,
        'phone_number': phone,
        if (uploadedAvatarUrl != null && uploadedAvatarUrl.isNotEmpty)
          'avatar_url': uploadedAvatarUrl,
      };

      await _supabase.auth.updateUser(
        UserAttributes(
          email: email != _initialEmail ? email : null,
          data: updatedMeta,
        ),
      );

      final profilePayload = <String, dynamic>{
        'full_name': name,
        'name': name,
        'shop_name': shopName,
        'email': email,
        'phone': phone,
        if (uploadedAvatarUrl != null && uploadedAvatarUrl.isNotEmpty)
          'avatar_url': uploadedAvatarUrl,
      };

      try {
        await _supabase
            .from('profiles')
            .update(profilePayload)
            .eq('id', user.id);
      } catch (_) {
        try {
          await _supabase
              .from('users')
              .update(profilePayload)
              .eq('id', user.id);
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _avatarUrl = uploadedAvatarUrl;
        _selectedAvatarBytes = null;
        _initialEmail = email;
        _isSavingProfile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF1CB454),
          content: Text('Profile updated successfully!'),
        ),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSavingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE52E2E),
          content: Text('Failed to update profile: $e'),
        ),
      );
    }
  }

  Future<void> _submitAddress() async {
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

      final addressPayload = <String, dynamic>{
        'street': street,
        'city': city,
        'postal_code': postalCode,
      };

      try {
        await _supabase
            .from('profiles')
            .update(addressPayload)
            .eq('id', user.id);
      } catch (_) {
        try {
          await _supabase
              .from('users')
              .update(addressPayload)
              .eq('id', user.id);
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _initialStreet = street;
        _initialCity = city;
        _initialPostalCode = postalCode;
        _isSavingAddress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF1CB454),
          content: Text('Address updated successfully!'),
        ),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSavingAddress = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE52E2E),
          content: Text('Failed to update address: $e'),
        ),
      );
    }
  }

  void _cancelAddressEdit() {
    _streetController.text = _initialStreet;
    _cityController.text = _initialCity;
    _postalCodeController.text = _initialPostalCode;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address changes discarded.')),
      );
    }
  }

  Future<void> _handleSignOut() async {
    await _supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
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
      appBar: const CustomTopBar(activePage: ''),
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

            // Top Section: Edit Profile Form
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
                  // Profile Avatar with Camera Icon (Clickable to pick photo)
                  Tooltip(
                    message: 'Change profile photo',
                    child: InkWell(
                      onTap: _pickAvatar,
                      borderRadius: BorderRadius.circular(70),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAEDE8),
                          shape: BoxShape.circle,
                          image: _selectedAvatarBytes != null
                              ? DecorationImage(
                                  image: MemoryImage(_selectedAvatarBytes!),
                                  fit: BoxFit.cover,
                                )
                              : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(_avatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (_selectedAvatarBytes != null ||
                                    (_avatarUrl != null &&
                                        _avatarUrl!.isNotEmpty))
                                ? Colors.black.withOpacity(0.25)
                                : Colors.transparent,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),

                  // Edit Forms
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEditableTextField(
                          'Name',
                          _nameController,
                          hint: _isLoading ? 'Loading...' : 'Enter your name',
                        ),
                        const SizedBox(height: 16),
                        _buildEditableTextField(
                          'Shop Name',
                          _shopNameController,
                          hint: _isLoading
                              ? 'Loading...'
                              : 'Enter your public shop name',
                        ),
                        const SizedBox(height: 16),
                        _buildEditableTextField(
                          'Email',
                          _emailController,
                          hint: _isLoading ? 'Loading...' : 'Enter your email',
                        ),
                        const SizedBox(height: 16),
                        _buildEditableTextField(
                          'Phone Number',
                          _phoneController,
                          hint: _isLoading
                              ? 'Loading...'
                              : 'Enter your phone number',
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
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed:
                              (_isLoading || _isSavingProfile) ? null : _submitProfile,
                          child: Text(
                            _isSavingProfile ? 'Saving...' : 'Submit',
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
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Section: Address & Transaction History
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Edit Address Form (Flex 7)
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
                        _buildEditableTextField(
                          'Street',
                          _streetController,
                          hint: 'Enter street address',
                        ),
                        const SizedBox(height: 16),
                        _buildEditableTextField(
                          'City',
                          _cityController,
                          hint: 'Enter city',
                        ),
                        const SizedBox(height: 16),
                        _buildEditableTextField(
                          'Postal code',
                          _postalCodeController,
                          hint: 'Enter postal code',
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed:
                                  _isSavingAddress ? null : _cancelAddressEdit,
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                              onPressed: (_isLoading || _isSavingAddress)
                                  ? null
                                  : _submitAddress,
                              child: Text(
                                _isSavingAddress ? 'Saving...' : 'Submit',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Transaction History & Account Actions (Flex 3)
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

                      // Account Action Buttons (Logout & Switch Account)
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

  Widget _buildEditableTextField(
    String label,
    TextEditingController controller, {
    String hint = '',
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
