import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowingResponse {
  late String decisionMakerId;
  late bool approved;
  String? details;
  DateTime? createdAt;

  BorrowingResponse({
    required this.decisionMakerId,
    required this.approved,
    this.details,
    this.createdAt,
  });

  static BorrowingResponse fromFirestore(Map<String, dynamic> data) {
    return BorrowingResponse(
      decisionMakerId: data['decisionMakerId'],
      approved: data['approved'],
      details: data['details'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'decisionMakerId': decisionMakerId,
      'approved': approved,
      'details': details,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
  }
}
