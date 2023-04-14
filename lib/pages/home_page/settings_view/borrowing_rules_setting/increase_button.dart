part of 'borrowing_rules_setting.dart';

class IncreaseButton extends StatelessWidget {
  final BorrowingRule rule;

  const IncreaseButton({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    final borrowingRuleRepository = context.read<BorrowingRuleRepository>();

    return AsyncIconButton(
      onPressed: () async {
        rule.maxBorrowingCount++;
        await borrowingRuleRepository.update(rule);
      },
      icon: Icons.add,
    );
  }
}
