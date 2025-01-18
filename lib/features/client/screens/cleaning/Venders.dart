import 'package:flutter/material.dart';

class Venders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendors'),
        backgroundColor: Colors.blue,
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
