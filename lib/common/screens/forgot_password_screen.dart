import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  String? _message;
  bool _isSuccess = false;
  bool _isLoading = false;

  Future<void> _sendResetEmail() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _isSuccess = false;
        _message = 'Please enter your email address.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Sending reset link...';
    });

    try {
      await _auth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      setState(() {
        _isSuccess = true;
        _message = 'Password reset link sent! Please check your email.';
        _isLoading = false;
      });

      // Wait for 3 seconds then navigate back to login
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              _message = 'No user found with this email address.';
              break;
            case 'invalid-email':
              _message = 'Please enter a valid email address.';
              break;
            default:
              _message = 'Error: ${e.message}';
          }
        } else {
          _message = 'An error occurred. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFF2B5F56),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(height: 20),
                // Lottie Animation
                Center(
                  child: Container(
                    height: screenSize.height * 0.3,
                    width: screenSize.width * 0.8,
                    child: Lottie.asset(
                      'assets/animations/login.json',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      repeat: true,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Title
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB74D),
                  ),
                ),
                Text(
                  'Reset via Email',
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
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon:
                          Icon(Icons.email_outlined, color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Send Reset Link Button
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2D6A4F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Send Reset Link',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isSuccess ? Colors.green[300] : Colors.red[300],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                SizedBox(height: 16),
                // Back to Login Button
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
                      'Back to Login',
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
