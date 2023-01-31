part of 'borrowing_rules_setting.dart';

class NewRuleButton extends StatelessWidget {
  final List<BorrowingRule> rules;

  const NewRuleButton({
    Key? key,
    required this.rules,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    
    return ElevatedButton(
      onPressed: () async {
        final ruleTypes = rules.map((rule) => rule.type);
        final firstAvailableType = itemTypes.keys
            .firstWhere((type) => !ruleTypes.contains(type));
        await firestoreService.addBorrowingRule(BorrowingRule(
          type: firstAvailableType,
          maxBorrowingCount: 1,
        ));
      },
      child: Text('Add Rule'),
    );
  }
}