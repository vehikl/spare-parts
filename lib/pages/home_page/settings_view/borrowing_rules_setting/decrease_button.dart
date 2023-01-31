part of 'borrowing_rules_setting.dart';

class DecreaseButton extends StatelessWidget {
  final BorrowingRule rule;
  const DecreaseButton({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

    return IconButton(
      onPressed: () async {
        rule.maxBorrowingCount--;
        await firestoreService.updateBorrowingRule(rule);
      },
      icon: Icon(Icons.remove),
    );
  }
}
