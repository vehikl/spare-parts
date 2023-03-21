import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowingResponse {
  late String decisionMakerId;
  late bool accepted;
  String? details;
  DateTime? createdAt;

  BorrowingResponse({
    required this.decisionMakerId,
    required this.accepted,
    this.details,
    this.createdAt,
  });

  static BorrowingResponse fromFirestore(Map<String, dynamic> data) {
    return BorrowingResponse(
      decisionMakerId: data['decisionMakerId'],
      accepted: data['accepted'],
      details: data['details'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'decisionMakerId': decisionMakerId,
      'accepted': accepted,
      'details': details,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
  }
}
