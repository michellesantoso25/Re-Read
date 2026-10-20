import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/navbar.dart';
import '../main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name, Email and Password must be filled.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Register ke Supabase
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phone,
        },
      );

      // 2. Jika session belum aktif otomatis, langsung paksa sign in
      if (res.session == null) {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Failed: ${error.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: const CustomNavbar(),
      body: Row(
        children: [
          // Left Banner
          if (isDesktop)
            Expanded(
              flex: 4,
              child: Container(
                color: const Color(0xFF22201F),
                padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'lib/assets/logo.png',
                      height: 38,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE05627), width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      },
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good books\ndeserve another\nchapter.',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Buy thoughtfully, sell simply, and keep stories in circulation.',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'A circular marketplace for curious readers.',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          // Right Banner
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFFECE6DF),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create your account',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22201F),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Join thousands of readers giving books a second life.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          'Full name',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF22201F),
                          ),
                        ),

                        const SizedBox(height: 4),

                        SizedBox(
                          height: 38,
                          child: TextField(
                            controller: _fullNameController,
                            style: GoogleFonts.inter(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Enter full name',
                              hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Email address',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF22201F),
                          ),
                        ),

                        const SizedBox(height: 4),

                        SizedBox(
                          height: 38,
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Enter email address',
                              hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Password',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF22201F),
                          ),
                        ),

                        const SizedBox(height: 4),

                        SizedBox(
                          height: 38,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: GoogleFonts.inter(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Enter password',
                              hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Phone number',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF22201F),
                          ),
                        ),

                        const SizedBox(height: 4),

                        SizedBox(
                          height: 38,
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.inter(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Enter phone number',
                              hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE05627),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _isLoading ? null : _signUp,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Create account',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.black54),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: Text(
                                'Log in',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22201F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}