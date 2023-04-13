import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/entities/custom_user.dart';

class BorrowingResponse {
  late CustomUser decisionMaker;
  late bool approved;
  String? details;
  DateTime? createdAt;

  BorrowingResponse({
    required this.decisionMaker,
    required this.approved,
    this.details,
    this.createdAt,
  });

  static BorrowingResponse fromFirestore(Map<String, dynamic> data) {
    return BorrowingResponse(
      decisionMaker: CustomUser.fromFirestore(data['decisionMaker']),
      approved: data['approved'],
      details: data['details'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'decisionMaker': decisionMaker.toFirestore(),
      'approved': approved,
      'details': details,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
  }
}
