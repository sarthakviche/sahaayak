import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'main.dart'; // Import to use the supabase client

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool isPasswordStrong(String password) {
    if (password.length < 6) return false;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    return hasUppercase && hasLowercase && hasNumber;
  }

  Future<void> _handleAuthAction(Future<void> Function() authAction) async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      await authAction();
    } on AuthException catch (e) {
      _showAlertDialog('Authentication Failed', e.message);
    } catch (e) {
      _showAlertDialog('Error', 'An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signIn() async {
    await _handleAuthAction(() async {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    });
  }

  Future<void> _signUp() async {
    await _handleAuthAction(() async {
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
       _showAlertDialog(
        'Sign Up Successful',
        'Please check your email to confirm your account.',
      );
    });
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.lato()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.deepPurple.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(
              bottom: -50,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/images/calm_wave.svg',
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.5), BlendMode.srcIn),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.spa_outlined, size: 60, color: Colors.purple.shade200),
                      const SizedBox(height: 16),
                      Text(
                        'Sahayaak',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your companion for mental wellness.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration(
                          labelText: 'VIT Email Address',
                          prefixIcon: Icons.email_outlined,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || !value.trim().endsWith('@vit.edu')) {
                            return 'A valid @vit.edu email is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: _buildInputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icons.lock_outline,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || !isPasswordStrong(value)) {
                            return 'Password must be strong (6+ chars, A-Z, a-z, 0-9)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32.0),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildGradientButton(),
                      const SizedBox(height: 24.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.lato(color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: _isLoading ? null : _signUp,
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.lato(
                                color: Colors.deepPurple.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : () { /* TODO: Forgot Password */ },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.lato(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String labelText, required IconData prefixIcon}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon, color: Colors.purple.shade200),
      fillColor: Colors.white.withOpacity(0.8),
      filled: true,
      // ✅ --- THIS LINE CONTROLS THE TEXTBOX HEIGHT --- ✅
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.purple.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
      ),
      labelStyle: GoogleFonts.lato(color: Colors.grey.shade600),
    );
  }

  Widget _buildGradientButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.purple.shade300, Colors.deepPurple.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          // ✅ --- THIS LINE CONTROLS THE BUTTON HEIGHT --- ✅
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: Text(
          'Log In',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}