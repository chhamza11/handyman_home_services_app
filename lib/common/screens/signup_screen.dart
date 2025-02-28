import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool _obscurePassword = true; // Password visibility toggle

  bool _validatePassword(String password) {
    setState(() {
      _passwordError = null; // Reset password error
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
    setState(() {
      _emailError = null; // Reset email error
      _passwordError = null; // Reset password error
    });

    // Validate password
    if (!_validatePassword(_passwordController.text.trim())) {
      setState(() {}); // Update UI to show password error
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to login screen after successful signup
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        // Handle authentication errors
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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenSize = constraints.biggest; // Get screen size
          return Container(
            // Full screen container
            width: screenSize.width,
            height: screenSize.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width *
                        0.05), // Responsive horizontal padding
                child: SingleChildScrollView(
                  // Allow scrolling for smaller screens
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center all children vertically
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Center all children horizontally
                    children: [
                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              screenSize.width * 0.08, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                          height: screenSize.height * 0.05), // Responsive space
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16), // Rounded corners
                        ),
                        elevation: 8, // Increased elevation for shadow
                        child: Padding(
                          padding: EdgeInsets.all(
                              screenSize.width * 0.05), // Responsive padding
                          child: Column(
                            children: [
                              // Email TextField with error handling
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  prefixIcon: const Icon(Icons.email),
                                ),
                              ),
                              if (_emailError !=
                                  null) // Show error below the email field
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _emailError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                  height: screenSize.height *
                                      0.02), // Responsive space
                              // Password TextField with show/hide toggle
                              TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscurePassword,
                              ),
                              if (_passwordError !=
                                  null) // Show error below the password field
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _passwordError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                  height: screenSize.height *
                                      0.05), // Responsive space
                              ElevatedButton(
                                onPressed: _signup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenSize.width *
                                        0.1, // Responsive padding
                                    vertical: screenSize.height *
                                        0.02, // Responsive padding
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12), // Rounded corners
                                  ),
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenSize.width *
                                          0.05), // Responsive font size
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                          height: screenSize.height * 0.02), // Responsive space
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
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
          );
        },
      ),
    );
  }
}
