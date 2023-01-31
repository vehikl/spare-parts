part of 'borrowing_rules_setting.dart';

class NewRuleButton extends StatelessWidget {
  final List<BorrowingRule> rules;
  final bool isIcon;

  const NewRuleButton({
    Key? key,
    required this.rules,
    this.isIcon = false,
  }) : super(key: key);

  void _handlePress(FirestoreService firestoreService) async {
    final ruleTypes = rules.map((rule) => rule.type);
    final firstAvailableType =
        itemTypes.keys.firstWhere((type) => !ruleTypes.contains(type));
    await firestoreService.addBorrowingRule(BorrowingRule(
      type: firstAvailableType,
      maxBorrowingCount: 1,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    if (isIcon) {
      return IconButton(
        onPressed: () => _handlePress(firestoreService),
        icon: Icon(Icons.add),
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return ElevatedButton(
      onPressed: () => _handlePress(firestoreService),
      child: Text('Add Rule'),
    );
  }
}
