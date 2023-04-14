import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/entities/borrowing_rule.dart';
import 'package:spare_parts/services/firestore_service.dart';

class BorrowingRuleRepository extends FirestoreService {
  BorrowingRuleRepository(super.firestore);


  Stream<List<BorrowingRule>> borrowingRulesStream() {
    return borrowingRulesCollection.snapshots().map((e) => e.docs
        .map((doc) => BorrowingRule.fromFirestore(
            doc as QueryDocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  Future<BorrowingRule?> getForItemType(String itemType) async {
    final borrowingRuleDocs =
        await borrowingRulesCollection.where('type', isEqualTo: itemType).get();

    if (borrowingRuleDocs.docs.isEmpty) return null;

    return BorrowingRule.fromFirestore(borrowingRuleDocs.docs.first
        as QueryDocumentSnapshot<Map<String, dynamic>>);
  }

  Future<void> update(BorrowingRule borrowingRule) async {
    await borrowingRulesCollection.doc(borrowingRule.id).update(
          borrowingRule.toFirestore(),
        );
  }

  Future<void> add(BorrowingRule borrowingRule) async {
    await borrowingRulesCollection.add(borrowingRule.toFirestore());
  }

  Future<void> delete(BorrowingRule borrowingRule) async {
    await borrowingRulesCollection.doc(borrowingRule.id).delete();
  }

  Future<dynamic> getBorrowingCount(String itemType, String uid) async {
    final items = await itemsCollection
        .where('type', isEqualTo: itemType)
        .where('borrowerId', isEqualTo: uid)
        .get();

    return items.docs.length;
  }
}