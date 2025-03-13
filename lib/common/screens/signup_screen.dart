import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  bool _validatePassword(String password) {
    setState(() {
      _passwordError = null;
    });

    if (password.length < 8) {
      _passwordError = 'Password must be at least 8 characters long.';
      return false;
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      _passwordError = 'Password must include at least one letter.';
      return false;
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      _passwordError = 'Password must include at least one number.';
      return false;
    }
    if (!RegExp(r'[@$!%*?&]').hasMatch(password)) {
      _passwordError = 'Password must include at least one special character.';
      return false;
    }
    return true;
  }

  Future<void> _signup() async {
    if (!_validatePassword(_passwordController.text.trim())) {
      setState(() {});
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        if (e.toString().contains('email-already-in-use')) {
          _emailError = 'This email is already registered. Please log in!';
        } else if (e.toString().contains('invalid-email')) {
          _emailError = 'Please enter a valid email address.';
        } else {
          _emailError = 'An unexpected error occurred. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFF2B5F56), // Dark green background
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(height: 20),
                // Image placeholder
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50.0),
                    child: Container(
                      height: screenSize.height * 0.2, // 30% of screen height
                      width: screenSize.width * 0.8, // 80% of screen width
                      child: Lottie.asset(
                        'assets/animations/login.json',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        repeat: true, // Animation will loop
                        animate: true,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // App Name
                Text(
                  'Handy Man',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB74D),
                  ),
                ),
                Text(
                  'HOME SERVICES APP',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 40),
                // Email Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon:
                          Icon(Icons.email_outlined, color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      errorText: _emailError,
                      errorStyle: TextStyle(color: Colors.red[300]),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Password Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon:
                          Icon(Icons.lock_outline, color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      errorText: _passwordError,
                      errorStyle: TextStyle(color: Colors.red[300]),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Sign Up Button
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2D6A4F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Or divider
                Text(
                  'or',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 16),
                // Login Link
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
