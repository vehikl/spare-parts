import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/borrowing_rule.dart';
import 'package:spare_parts/services/repositories/repositories.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/dialogs/value_selection_dialog.dart';

class ItemTypeEditButton extends StatelessWidget {
  final List<BorrowingRule> existingRules;
  final BorrowingRule rule;

  const ItemTypeEditButton({
    super.key,
    required this.rule,
    required this.existingRules,
  });

  @override
  Widget build(BuildContext context) {
    final borrowingRuleRepository = context.read<BorrowingRuleRepository>();

    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () async {
        final selectedTypes = await showDialog<List<String>?>(
          context: context,
          builder: (context) => ValueSelectionDialog(
            isSingleSelection: true,
            title: 'Select Item Type',
            values: itemTypes.keys.toList(),
            selectedValues:
                itemTypes.keys.where((type) => type == rule.type).toList(),
            labelBuilder: (type) => type,
            disabledValues: existingRules
                .where((otherRule) => otherRule != rule)
                .map((rule) => rule.type)
                .toList(),
          ),
        );

        if (selectedTypes != null) {
          rule.type = selectedTypes.first;
          await borrowingRuleRepository.update(rule);
        }
      },
    );
  }
}
