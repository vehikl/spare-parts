part of 'borrowing_rules_setting.dart';

class DecreaseButton extends StatelessWidget {
  final BorrowingRule rule;
  const DecreaseButton({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

    return AsyncIconButton(
      onPressed: () async {
        await firestoreService.updateBorrowingRule(rule.copy..decrease());
      },
      icon: Icons.remove,
    );
  }
}
