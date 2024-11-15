import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Successfully logged in
      Navigator.pushReplacementNamed(context, '/client_dashboard');
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          // Center the content
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [
                const Text(
                  'Welcome', // Welcome text
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold), // Style for the welcome text
                ),
                const SizedBox(height: 20), // Spacing below the welcome text
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(), // Add border
                    filled: true, // Fill background
                    fillColor: Colors.grey[200], // Light background color
                    prefixIcon: const Icon(Icons.email), // Added icon
                  ),
                ),
                const SizedBox(height: 16), // Increased spacing
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(), // Add border
                    filled: true, // Fill background
                    fillColor: Colors.grey[200], // Light background color
                    prefixIcon: const Icon(Icons.lock), // Added icon
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login, // Larger text
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12), // Padding
                  ),
                  child: Text('Login', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Don\'t have an account? Sign up',
                      style: TextStyle(
                          color: Colors.blueAccent)), // Change text color
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
