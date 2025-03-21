import 'package:flutter/material.dart';

class Venders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendors'),
        backgroundColor: Color(0xFF2B5F56),
      ),
      body: Center(
        child: Text(
          'Select a vendor for your cleaning service.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
