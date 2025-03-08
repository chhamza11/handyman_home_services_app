class ServiceRequest {
  final String requestId;
  final String clientId;
  final String clientName;
  final String mainCategory;    // e.g., "Furniture Repair", "Solar Services"
  final String subCategory;     // e.g., "Office Furniture", "Solar Installation"
  final String contactNumber;
  final String selectedDate;
  final String selectedTime;
  final double priceRange;
  final String city;
  final String status;         // "pending", "assigned", "completed"
  final Map<String, dynamic> categorySpecificDetails;
  final String? vendorId;
  final String? vendorName;
  final DateTime createdAt;
  final DateTime? assignedAt;

  ServiceRequest({
    required this.requestId,
    required this.clientId,
    required this.clientName,
    required this.mainCategory,
    required this.subCategory,
    required this.contactNumber,
    required this.selectedDate,
    required this.selectedTime,
    required this.priceRange,
    required this.city,
    required this.categorySpecificDetails,
    this.status = 'pending',
    this.vendorId,
    this.vendorName,
    required this.createdAt,
    this.assignedAt,
  });

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'clientId': clientId,
    'clientName': clientName,
    'mainCategory': mainCategory,
    'subCategory': subCategory,
    'contactNumber': contactNumber,
    'selectedDate': selectedDate,
    'selectedTime': selectedTime,
    'priceRange': priceRange,
    'city': city,
    'status': status,
    'categorySpecificDetails': categorySpecificDetails,
    'vendorId': vendorId,
    'vendorName': vendorName,
    'createdAt': createdAt.toIso8601String(),
    'assignedAt': assignedAt?.toIso8601String(),
  };
} 