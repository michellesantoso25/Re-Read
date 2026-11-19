import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:reread/components/topbar.dart';
import 'package:reread/main.dart';
import 'package:reread/services/file_picker_registration_stub.dart'
    if (dart.library.io) 'package:reread/services/file_picker_registration_io.dart'
    if (dart.library.js_interop) 'package:reread/services/file_picker_registration_web.dart'
    as picker_registration;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _postal = TextEditingController();
  bool _editingAddress = false;
  bool _saving = false;
  bool _uploadingAvatar = false;
  bool _pickerRegistered = false;
  String? _avatarUrl;
  String? _avatarPath;

  User? get _user => supabase.auth.currentUser;
  Map<String, dynamic> get _metadata => _user?.userMetadata ?? {};

  @override
  void initState() {
    super.initState();
    _loadMetadata();
    _loadProfileRecord();
  }

  void _loadMetadata() {
    final metadata = _metadata;
    _name.text = (metadata['full_name'] ?? metadata['name'] ?? '').toString();
    _street.text = (metadata['street'] ?? '').toString();
    _city.text = (metadata['city'] ?? '').toString();
    _postal.text = (metadata['postal_code'] ?? '').toString();
  }

  Future<void> _loadProfileRecord() async {
    final user = _user;
    if (user == null) return;
    try {
      final profile = await supabase
          .from('profiles')
          .select(
            'full_name, street, city, postal_code, avatar_url, avatar_path',
          )
          .eq('id', user.id)
          .maybeSingle();
      final avatarUrl = profile?['avatar_url']?.toString();
      if (mounted && profile != null) {
        setState(() {
          _name.text = (profile['full_name'] ?? _name.text).toString();
          _street.text = (profile['street'] ?? _street.text).toString();
          _city.text = (profile['city'] ?? _city.text).toString();
          _postal.text = (profile['postal_code'] ?? _postal.text).toString();
          if (avatarUrl != null && avatarUrl.isNotEmpty) {
            _avatarUrl = avatarUrl;
          }
          _avatarPath = profile['avatar_path']?.toString();
        });
      }
    } catch (_) {
      // Auth metadata remains the fallback until the profiles migration is applied.
    }
    try {
      final userRecord = await supabase
          .from('users')
          .select('phone_number')
          .eq('id', user.id)
          .maybeSingle();
      if (mounted && userRecord != null) {
        setState(
          () => _phone.text = (userRecord['phone_number'] ?? '').toString(),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _phone.text = (_metadata['phone_number'] ?? _metadata['phone'] ?? '')
              .toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _street.dispose();
    _city.dispose();
    _postal.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = _user;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      final updatedUser = await supabase
          .from('users')
          .update({'phone_number': _phone.text.trim()})
          .eq('id', user.id)
          .select('id')
          .maybeSingle();
      if (updatedUser == null) {
        throw StateError('Your account row was not found in the users table.');
      }
      await supabase.from('profiles').upsert(_profileRow(), onConflict: 'id');
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            ..._metadata,
            'full_name': _name.text.trim(),
            'phone_number': null,
          },
        ),
      );
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile and phone number saved successfully.'),
          ),
        );
      }
    } on AuthException catch (error) {
      _showSaveError(error.message);
    } catch (error) {
      _showSaveError('Failed to save phone number to users table: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveAddress() async {
    await _saveMetadata({
      'street': _street.text.trim(),
      'city': _city.text.trim(),
      'postal_code': _postal.text.trim(),
    });
    if (mounted) setState(() => _editingAddress = false);
  }

  Future<void> _saveMetadata(Map<String, dynamic> changes) async {
    setState(() => _saving = true);
    try {
      await supabase.from('profiles').upsert(_profileRow(), onConflict: 'id');
      await supabase.auth.updateUser(
        UserAttributes(data: {..._metadata, ...changes}),
      );
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully.')),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: ${error.message}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile to Supabase: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeAvatar() async {
    final user = _user;
    if (user == null) return;
    try {
      if (!_pickerRegistered) {
        picker_registration.ensureFilePickerRegistered();
        _pickerRegistered = true;
      }
      final selection = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      // The route can be disposed while the native/browser picker is open.
      // Never call setState after returning from that asynchronous plugin call.
      if (!mounted || selection == null || selection.files.isEmpty) return;
      final image = selection.files.single;
      final bytes = image.bytes;
      if (bytes == null) {
        _showAvatarError(
          'Unable to read the photo file. Please select another photo.',
        );
        return;
      }
      if (bytes.length > 5 * 1024 * 1024) {
        _showAvatarError('Maximum photo size is 5 MB.');
        return;
      }
      setState(() => _uploadingAvatar = true);
      final extension = image.name.split('.').last.toLowerCase();
      final safeExtension =
          const {'jpg', 'jpeg', 'png', 'webp'}.contains(extension)
          ? extension
          : 'jpg';
      final contentType = switch (safeExtension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      final path = '${user.id}/avatar.$safeExtension';
      final storage = supabase.storage.from('avatars');
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: contentType,
          cacheControl: '3600',
          upsert: true,
        ),
      );
      final publicUrl =
          '${storage.getPublicUrl(path)}?v=${DateTime.now().millisecondsSinceEpoch}';
      await supabase
          .from('profiles')
          .upsert(
            _profileRow(avatarUrl: publicUrl, avatarPath: path),
            onConflict: 'id',
          );
      await supabase.auth.updateUser(
        UserAttributes(data: {..._metadata, 'avatar_url': publicUrl}),
      );
      if (mounted) {
        setState(() {
          _avatarUrl = publicUrl;
          _avatarPath = path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated successfully.')),
        );
      }
    } on AuthException catch (error) {
      _showAvatarError(error.message);
    } on StorageException catch (error) {
      _showAvatarError(
        'Failed to upload photo. Make sure the avatars bucket and its permissions are configured. ${error.message}',
      );
    } catch (error) {
      _showAvatarError('Failed to update profile photo: $error');
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Map<String, dynamic> _profileRow({String? avatarUrl, String? avatarPath}) {
    final user = _user!;
    return {
      'id': user.id,
      'full_name': _name.text.trim(),
      'street': _street.text.trim(),
      'city': _city.text.trim(),
      'postal_code': _postal.text.trim(),
      'avatar_url': avatarUrl ?? _avatarUrl ?? _metadata['avatar_url'],
      'avatar_path': avatarPath ?? _avatarPath ?? _metadata['avatar_path'],
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  void _showSaveError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAvatarError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editProfile() async {
    final name = TextEditingController(text: _name.text);
    final phone = TextEditingController(text: _phone.text);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input('Full name', name),
            const SizedBox(height: 14),
            _input('Phone number', phone, keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _orange),
            onPressed: () {
              _name.text = name.text;
              _phone.text = phone.text;
              Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    name.dispose();
    phone.dispose();
    if (saved == true) await _saveProfile();
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  static const _orange = Color(0xFFFF4B00);
  static const _ink = Color(0xFF262323);

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return Scaffold(
        appBar: const CustomTopBar(activeNav: null),
        body: const Center(child: Text('Please sign in to view your profile.')),
      );
    }
    final email = user.email ?? 'Email not available';
    final displayName = _name.text.trim().isEmpty
        ? email.split('@').first
        : _name.text.trim();
    final avatarUrl = _avatarUrl ?? _metadata['avatar_url']?.toString();
    final accountType = (_metadata['account_type'] ?? _metadata['role'] ?? '')
        .toString()
        .toLowerCase();
    final isSeller = accountType.contains('seller');
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const CustomTopBar(activeNav: null),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width < 700 ? 18 : 32,
          vertical: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: width < 700
                      ? Alignment.center
                      : Alignment.centerLeft,
                  child: Text(
                    isSeller ? 'Seller Profile' : 'Your Profile',
                    textAlign: width < 700 ? TextAlign.center : TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: width < 700
                      ? Alignment.center
                      : Alignment.centerLeft,
                  child: Text(
                    isSeller
                        ? 'Manage your details, address, catalog, and transactions.'
                        : 'Manage your details, address, and transactions.',
                    textAlign: width < 700 ? TextAlign.center : TextAlign.left,
                    style: GoogleFonts.inter(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _card(
                  Padding(
                    padding: EdgeInsets.all(width < 700 ? 20 : 28),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 570;
                        final phone = _phone.text.trim();
                        final info = Column(
                          crossAxisAlignment: compact
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              textAlign: compact
                                  ? TextAlign.center
                                  : TextAlign.left,
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              email,
                              textAlign: compact
                                  ? TextAlign.center
                                  : TextAlign.left,
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                            if (phone.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                phone,
                                textAlign: compact
                                    ? TextAlign.center
                                    : TextAlign.left,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              '★  Re:Read member',
                              style: GoogleFonts.inter(
                                color: _orange,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Your catalog will be available soon.',
                                      ),
                                    ),
                                  ),
                              style: OutlinedButton.styleFrom(
                                shape: const StadiumBorder(),
                                side: const BorderSide(
                                  color: Color(0xFFE8D2C7),
                                ),
                              ),
                              child: const Text(
                                'View my catalog',
                                style: TextStyle(color: _ink),
                              ),
                            ),
                          ],
                        );
                        final avatar = InkWell(
                          onTap: _uploadingAvatar ? null : _changeAvatar,
                          customBorder: const CircleBorder(),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: compact ? 58 : 82,
                                backgroundColor: const Color(0xFFE9DED6),
                                backgroundImage:
                                    avatarUrl != null && avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: _uploadingAvatar
                                    ? const CircularProgressIndicator(
                                        color: _orange,
                                      )
                                    : avatarUrl == null || avatarUrl.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 58,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: const BoxDecoration(
                                    color: _orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        final edit = FilledButton(
                          onPressed: _saving ? null : _editProfile,
                          style: FilledButton.styleFrom(
                            backgroundColor: _orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          child: const Text('Edit Profile'),
                        );
                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              edit,
                              const SizedBox(height: 18),
                              Center(child: avatar),
                              const SizedBox(height: 18),
                              info,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            avatar,
                            const SizedBox(width: 18),
                            Expanded(child: info),
                            Align(alignment: Alignment.topRight, child: edit),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 760;
                    final address = _addressCard();
                    final history = _historyCard();
                    if (stacked) {
                      return Column(
                        children: [
                          address,
                          const SizedBox(height: 16),
                          history,
                          const SizedBox(height: 16),
                          _accountActions(),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: address),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              history,
                              const SizedBox(height: 10),
                              _accountActions(),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _addressCard() => _card(
    Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final centered = constraints.maxWidth < 570;
          return Column(
            crossAxisAlignment: centered
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                'My Address',
                textAlign: centered ? TextAlign.center : TextAlign.left,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _addressField('Street', _street),
              const SizedBox(height: 12),
              _addressField('City', _city),
              const SizedBox(height: 12),
              _addressField('Postal code', _postal),
              const SizedBox(height: 14),
              if (_editingAddress)
                Row(
                  mainAxisAlignment: centered
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    FilledButton(
                      onPressed: _saving ? null : _saveAddress,
                      style: FilledButton.styleFrom(backgroundColor: _orange),
                      child: const Text('Save address'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _editingAddress = false;
                          _loadMetadata();
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                )
              else
                FilledButton(
                  onPressed: () => setState(() => _editingAddress = true),
                  style: FilledButton.styleFrom(backgroundColor: _orange),
                  child: const Text('Edit Address'),
                ),
            ],
          );
        },
      ),
    ),
  );

  Widget _historyCard() => _card(
    Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final centered = constraints.maxWidth < 570;
          return Column(
            crossAxisAlignment: centered
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction history',
                textAlign: centered ? TextAlign.center : TextAlign.left,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Buyer',
                textAlign: centered ? TextAlign.center : TextAlign.left,
                style: GoogleFonts.inter(
                  color: _orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No transactions yet.',
                textAlign: centered ? TextAlign.center : TextAlign.left,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('See more'),
              ),
            ],
          );
        },
      ),
    ),
  );

  Widget _accountActions() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Center(
        child: Text(
          'Danger Zone!',
          style: GoogleFonts.inter(
            color: Colors.red,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
      const SizedBox(height: 6),
      FilledButton(
        onPressed: _signOut,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.red,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text('Sign out'),
      ),
      const SizedBox(height: 7),
      OutlinedButton(
        onPressed: _signOut,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text('Switch account'),
      ),
    ],
  );

  Widget _addressField(String label, TextEditingController controller) {
    final centered = MediaQuery.sizeOf(context).width < 700;
    if (!_editingAddress) {
      final value = controller.text.isEmpty ? 'Not set' : controller.text;
      return Column(
        crossAxisAlignment: centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: centered ? TextAlign.center : TextAlign.left,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE6CFC2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: centered ? Alignment.center : Alignment.centerLeft,
              child: Text(
                value,
                textAlign: centered ? TextAlign.center : TextAlign.left,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: controller.text.isEmpty ? Colors.black45 : _ink,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return _input(label, controller, centeredLabel: centered);
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool centeredLabel = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        textAlign: centeredLabel ? TextAlign.center : TextAlign.left,
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: centeredLabel ? TextAlign.center : TextAlign.start,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        style: GoogleFonts.inter(fontSize: 13),
      ),
    ],
  );

  Widget _card(Widget child) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xFFFFFEFD),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .035),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}