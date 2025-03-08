import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_services/features/client/screens/available_vendors_screen.dart';

import 'package:flutter/material.dart';

class ServiceRequestHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitServiceRequest({
    required String clientId,
    required Map<String, dynamic> serviceData,
    required BuildContext context,
  }) async {
    try {
      // Get client data
      DocumentSnapshot clientDoc = await _firestore
          .collection('clients')
          .doc(clientId)
          .get();
      
      Map<String, dynamic> clientData = clientDoc.data() as Map<String, dynamic>;

      // Create service request
      DocumentReference requestRef = await _firestore
          .collection('clients')
          .doc(clientId)
          .collection('serviceRequests')
          .add({
        ...serviceData,
        'clientId': clientId,
        'clientName': clientData['name'],
        'city': clientData['city'],
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Prepare the complete service request data
      Map<String, dynamic> completeServiceRequest = {
        ...serviceData,
        'requestId': requestRef.id,
        'clientId': clientId,
        'clientName': clientData['name'],
        'city': clientData['city'],
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add to main serviceRequests collection for vendors to see
      await _firestore
          .collection('serviceRequests')
          .doc(requestRef.id)
          .set(completeServiceRequest);

      // Navigate to available vendors
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AvailableVendorsScreen(
            serviceCategory: serviceData['mainCategory'],
            subCategory: serviceData['subCategory'],
            serviceRequest: completeServiceRequest, // Pass the complete service request data
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting request: $e')),
      );
    }
  }
} 