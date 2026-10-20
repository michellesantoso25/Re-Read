import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/navbar.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email and password must be filled.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      debugPrint('SIGN IN SUCCESS');
      debugPrint('User ID: ${response.user?.id}');

      if (!mounted) return;

      // Pindah langsung ke Homepage polos
      Navigator.pushReplacementNamed(context, '/home');
    } on AuthException catch (error) {
      if (!mounted) return;

      // Tangkap error spesifik Supabase dengan pesan yang manusiawi
      String errorMessage = error.message;
      if (error.message.contains('Invalid login credentials')) {
        errorMessage = 'Email atau password salah. Silakan periksa kembali.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Failed: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 50.0,
                  vertical: 40.0,
                ),
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
                            border: Border.all(
                              color: const Color(0xFFE05627),
                              width: 2,
                            ),
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
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Right Form Banner
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFFECE6DF),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 32.0,
                    ),
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
                          'Welcome back',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22201F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to continue your reading journey.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email Field
                        Text(
                          'Email address',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF22201F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 42,
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            style: GoogleFonts.inter(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Enter email address',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        Text(
                          'Password',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF22201F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 42,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            autocorrect: false,
                            enableSuggestions: false,
                            style: GoogleFonts.inter(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Enter password',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                              ),
                            ),
                            onSubmitted: (_) {
                              if (!_isLoading) _signIn();
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Sign in Button
                        SizedBox(
                          height: 42,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE05627),
                              disabledBackgroundColor:
                                  const Color(0xFFE05627).withOpacity(0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _isLoading ? null : _signIn,
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
                                    'Sign in',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New to Re:Read? ',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/register');
                              },
                              child: Text(
                                'Register',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
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