part of 'borrowing_rules_setting.dart';

class IncreaseButton extends StatelessWidget {
  final BorrowingRule rule;

  const IncreaseButton({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

    return IconButton(
      onPressed: () async {
        rule.maxBorrowingCount++;
        await firestoreService.updateBorrowingRule(rule);
      },
      icon: Icon(Icons.add),
    );
  }
}
