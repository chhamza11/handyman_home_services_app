// user_provider.dart 

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Try to get user data from clients collection
        final clientDoc = await FirebaseFirestore.instance
            .collection('clients')
            .doc(user.uid)
            .get();

        if (clientDoc.exists) {
          _userData = clientDoc.data();
        } else {
          // If not in clients, check vendors collection
          final vendorDoc = await FirebaseFirestore.instance
              .collection('vendors')
              .doc(user.uid)
              .get();

          if (vendorDoc.exists) {
            _userData = vendorDoc.data();
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearUserData() {
    _userData = null;
    notifyListeners();
  }
} 