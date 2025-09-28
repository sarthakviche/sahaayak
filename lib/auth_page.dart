import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  bool isPasswordStrong(String password) {
    if (password.length < 6) return false;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    return hasUppercase && hasLowercase && hasNumber;
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!email.endsWith('@vit.edu')) {
      _showAlertDialog('Invalid Email', 'Please use a vit.edu email address.');
      return;
    }

    if (!isPasswordStrong(password)) {
      _showAlertDialog(
        'Password Not Strong Enough',
        'Your password must be at least 6 characters long and contain a mix of uppercase letters, lowercase letters, and numbers.',
      );
      return;
    }

    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      _showAlertDialog('Login Failed', e.message);
    } catch (e) {
      _showAlertDialog(
        'Error',
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!email.endsWith('@vit.edu')) {
      _showAlertDialog('Invalid Email', 'Please use a vit.edu email address.');
      return;
    }

    if (!isPasswordStrong(password)) {
      _showAlertDialog(
        'Password Not Strong Enough',
        'Your password must be at least 6 characters long and contain a mix of uppercase letters, lowercase letters, and numbers.',
      );
      return;
    }

    try {
      await supabase.auth.signUp(email: email, password: password);
      _showAlertDialog(
        'Sign Up Successful',
        'Please check your email to confirm your account.',
      );
    } on AuthException catch (e) {
      _showAlertDialog('Sign Up Failed', e.message);
    } catch (e) {
      _showAlertDialog(
        'Error',
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5E6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Sahayaak',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A8E3F),
                  ),
                ),
                const SizedBox(height: 50.0),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Your companion for mental wellness.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 40.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || !value.endsWith('@vit.edu')) {
                      return 'Must be a vit.edu email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || !isPasswordStrong(value)) {
                      return '6+ chars, uppercase, lowercase, number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF75A64E),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Color(0xFF666666)),
                    ),
                    TextButton(
                      onPressed: _signUp,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF5A8E3F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement Forgot Password logic
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Color(0xFF5A8E3F)),
                  ),
                ),
                const SizedBox(height: 100.0),
                const Text(
                  '© 2024 Sahayaak. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
