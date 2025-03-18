import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorRequestHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getAvailableRequests({
    required String vendorId,
    required String city,
    required List<String> serviceCategories,
    required List<String> subCategories,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('serviceRequests')
          .where('status', isEqualTo: 'pending')
          .where('city', isEqualTo: city);

      if (serviceCategories.isNotEmpty) {
        query = query.where('mainCategory', whereIn: serviceCategories);
      }

      return query
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting available requests: $e');
      rethrow;
    }
  }

  Future<void> acceptServiceRequest({
    required String requestId,
    required String vendorId,
    required String vendorName,
    required BuildContext context,
  }) async {
    try {
      // First check if the request exists and is in the correct state
      final requestDoc = await _firestore
          .collection('serviceRequests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw Exception('Request not found');
      }

      final requestData = requestDoc.data() as Map<String, dynamic>;

      // Update the request status
      await _firestore
          .collection('serviceRequests')
          .doc(requestId)
          .update({
            'status': 'accepted',
            'acceptedAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request accepted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error accepting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> rejectServiceRequest({
    required String requestId,
    required String vendorId,
    required String reason,
    required BuildContext context,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final requestRef = _firestore.collection('serviceRequests').doc(requestId);
        final requestDoc = await transaction.get(requestRef);

        if (!requestDoc.exists) {
          throw Exception('Request not found');
        }

        transaction.update(requestRef, {
          'status': 'rejected',
          'rejectedBy': vendorId,
          'rejectionReason': reason,
          'rejectedAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request rejected'),
          backgroundColor: Colors.orange,
        ),
      );

    } catch (e) {
      print('Error rejecting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to get vendor details
  Future<Map<String, dynamic>?> getVendorDetails(String vendorId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> vendorDoc =
      await _firestore.collection('vendors').doc(vendorId).get();

      return vendorDoc.data();
    } catch (e) {
      print('Error getting vendor details: $e');
      return null;
    }
  }

  // Helper method to check if request is still available
  Future<bool> isRequestAvailable(String requestId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> requestDoc =
      await _firestore.collection('serviceRequests').doc(requestId).get();

      return requestDoc.exists &&
          requestDoc.data()?['status'] == 'pending';
    } catch (e) {
      print('Error checking request availability: $e');
      return false;
    }
  }

  Future<void> completeServiceRequest({
    required String requestId,
    required String vendorId,
    required BuildContext context,
    required double priceRange,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final requestRef = _firestore.collection('serviceRequests').doc(requestId);
        final vendorStatsRef = _firestore.collection('vendorStats').doc(vendorId);
        
        // Get current documents
        final requestDoc = await transaction.get(requestRef);
        final vendorStatsDoc = await transaction.get(vendorStatsRef);
        
        if (!requestDoc.exists) {
          throw Exception('Request not found');
        }

        // Update request status
        transaction.update(requestRef, {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'finalAmount': priceRange,
        });

        // Update vendor stats
        if (!vendorStatsDoc.exists) {
          transaction.set(vendorStatsRef, {
            'totalEarnings': priceRange,
            'totalOrders': 1,
            'completedOrders': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          final currentStats = vendorStatsDoc.data() as Map<String, dynamic>;
          transaction.update(vendorStatsRef, {
            'totalEarnings': (currentStats['totalEarnings'] ?? 0.0) + priceRange,
            'completedOrders': (currentStats['completedOrders'] ?? 0) + 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error completing request: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 