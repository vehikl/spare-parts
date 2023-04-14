part of 'borrowing_rules_setting.dart';

class DecreaseButton extends StatelessWidget {
  final BorrowingRule rule;
  const DecreaseButton({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    final borrowingRuleRepository = context.read<BorrowingRuleRepository>();

    return AsyncIconButton(
      onPressed: () async {
        await borrowingRuleRepository.update(rule.copy..decrease());
      },
      icon: Icons.remove,
    );
  }
}
