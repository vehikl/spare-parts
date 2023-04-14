part of 'borrowing_rules_setting.dart';

class DeleteButton extends StatelessWidget {
  final BorrowingRule rule;
  const DeleteButton({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    final borrowingRuleRepository = context.read<BorrowingRuleRepository>();

    return AsyncIconButton(
      onPressed: () async {
        await borrowingRuleRepository.delete(rule);
      },
      icon: Icons.delete,
      color: Theme.of(context).errorColor,
    );
  }
}
