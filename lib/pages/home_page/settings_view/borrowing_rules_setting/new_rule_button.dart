part of 'borrowing_rules_setting.dart';

class NewRuleButton extends StatefulWidget {
  final List<BorrowingRule> rules;
  final bool isIcon;

  const NewRuleButton({
    Key? key,
    required this.rules,
    this.isIcon = false,
  }) : super(key: key);

  @override
  State<NewRuleButton> createState() => _NewRuleButtonState();
}

class _NewRuleButtonState extends State<NewRuleButton> {
  Future<void> _handlePress(FirestoreService firestoreService) async {
    final ruleTypes = widget.rules.map((rule) => rule.type);
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
    if (widget.isIcon) {
      return AsyncIconButton(
        onPressed: () => _handlePress(firestoreService),
        icon: Icons.add_box,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return AsyncElevatedButton(
      onPressed: () => _handlePress(firestoreService),
      text: 'Add Rule',
    );
  }
}
