import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Get the main request document reference
      DocumentReference<Map<String, dynamic>> mainRequestRef = _firestore
          .collection('serviceRequests')
          .doc(requestId);

      // Get the request data first
      DocumentSnapshot<Map<String, dynamic>> requestDoc = 
          await mainRequestRef.get();

      if (!requestDoc.exists) {
        throw Exception('Request not found');
      }

      Map<String, dynamic> requestData = requestDoc.data() ?? {};
      
      // Prepare update data
      Map<String, dynamic> updateData = {
        'status': 'assigned',
        'vendorId': vendorId,
        'vendorName': vendorName,
        'assignedAt': FieldValue.serverTimestamp(),
      };

      // Update main request
      batch.update(mainRequestRef, updateData);

      // Update client's request
      if (requestData['clientId'] != null) {
        DocumentReference<Map<String, dynamic>> clientRequestRef = _firestore
            .collection('clients')
            .doc(requestData['clientId'])
            .collection('serviceRequests')
            .doc(requestId);

        batch.update(clientRequestRef, updateData);
      }

      // Add to vendor's assigned requests
      DocumentReference<Map<String, dynamic>> vendorRequestRef = _firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('assignedRequests')
          .doc(requestId);

      batch.set(vendorRequestRef, {
        ...requestData,
        ...updateData,
      });

      // Commit the batch
      await batch.commit();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service request accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
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
} 