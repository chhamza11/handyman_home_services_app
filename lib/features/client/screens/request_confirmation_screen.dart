import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'FlutterLocalNotificationsPlugin.dart';

class RequestConfirmationScreen extends StatelessWidget {
  final String requestId;
  final String? vendorName;

  const RequestConfirmationScreen({
    Key? key, 
    required this.requestId,
    this.vendorName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Details'),
        backgroundColor: Color(0xFF2B5F56),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('serviceRequests')
            .doc(requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Request not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final categoryDetails = data['categorySpecificDetails'] as Map<String, dynamic>?;

          // Trigger notification on status change
          _handleStatusChange(data['status'], context);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(data['status'] ?? 'pending'),
                SizedBox(height: 16),
                _buildDetailsCard(data, categoryDetails),
                if (data['vendorName'] != null) ...[
                  SizedBox(height: 16),
                  _buildVendorCard(data),
                ],
                if (data['status'] == 'rejected') ...[
                  SizedBox(height: 16),
                  _buildRejectionCard(data),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleStatusChange(String status, BuildContext context) {
    String title = '';
    String body = '';

    switch (status.toLowerCase()) {
      case 'accepted':
        title = 'Order Accepted';
        body = 'Your order has been accepted by $vendorName';
        break;
      case 'rejected':
        title = 'Order Rejected';
        body = 'Your order has been rejected';
        break;
      case 'completed':
        title = 'Order Completed';
        body = 'Your order has been completed';
        break;
    }

    if (title.isNotEmpty) {
      showNotification(
        title: title,
        body: body,
        context: context,
        payload: requestId,
      );
    }
  }

  Widget _buildStatusCard(String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'completed':
        statusColor = Color(0xFF2B5F56);
        statusIcon = Icons.task_alt;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor, size: 28),
        title: Text(
          'Status: ${status.toUpperCase()}',
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Map<String, dynamic> data, Map<String, dynamic>? categoryDetails) {
    String formattedDate = 'N/A';
    if (data['createdAt'] != null) {
      final timestamp = (data['createdAt'] as Timestamp).toDate();
      formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            _buildDetailRow('Category', data['mainCategory'] ?? 'N/A'),
            _buildDetailRow('Service', data['subCategory'] ?? 'N/A'),
            if (categoryDetails != null) ...[
              if (categoryDetails['cleaningServiceType'] != null)
                _buildDetailRow('Service Type', categoryDetails['cleaningServiceType']),
              if (categoryDetails['homeSize'] != null)
                _buildDetailRow('Home Size', categoryDetails['homeSize']),
              if (categoryDetails['roomQuantity'] != null)
                _buildDetailRow('Rooms', categoryDetails['roomQuantity']),
              if (categoryDetails['cleaningProducts'] != null)
                _buildDetailRow('Products', categoryDetails['cleaningProducts']),
              if (categoryDetails['specialRequests'] != null)
                _buildDetailRow('Special Requests', categoryDetails['specialRequests']),
            ],
            _buildDetailRow('Date', data['selectedDate'] ?? 'Not set'),
            _buildDetailRow('Time', data['selectedTime'] ?? 'Not set'),
            _buildDetailRow('Created On', formattedDate),
            _buildDetailRow('Price Range', 'Rs. ${data['priceRange']?.toString() ?? 'N/A'}'),
            _buildDetailRow('City', data['city'] ?? 'N/A'),
            _buildDetailRow('Contact', data['contactNumber'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendor Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            _buildDetailRow('Name', data['vendorName'] ?? 'Not assigned'),
            if (data['vendorPhone'] != null)
              _buildDetailRow('Contact', data['vendorPhone']),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionCard(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rejection Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Divider(),
            _buildDetailRow('Reason', data['rejectionReason'] ?? 'No reason provided'),
            if (data['rejectedAt'] != null)
              _buildDetailRow(
                'Rejected On',
                (data['rejectedAt'] as Timestamp)
                    .toDate()
                    .toString()
                    .split('.')[0],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 