part of 'borrowing_rules_setting.dart';

class DeleteButton extends StatelessWidget {
  final BorrowingRule rule;
  const DeleteButton({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

    return IconButton(
      onPressed: () async {
        await firestoreService.deleteBorrowingRule(rule);
      },
      icon: Icon(Icons.delete, color: Theme.of(context).errorColor),
    );
  }
}
