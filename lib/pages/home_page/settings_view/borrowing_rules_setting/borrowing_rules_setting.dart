import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/borrowing_rule.dart';
import 'package:spare_parts/pages/home_page/settings_view/borrowing_rules_setting/item_type_edit_button.dart';
import 'package:spare_parts/services/repositories/repositories.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/buttons/async_elevated_button.dart';
import 'package:spare_parts/widgets/buttons/async_icon_button.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/title_text.dart';

part 'decrease_button.dart';
part 'delete_button.dart';
part 'increase_button.dart';
part 'new_rule_button.dart';

class BorrowingRulesSetting extends StatelessWidget {
  const BorrowingRulesSetting({super.key});

  DataRow _buildRuleRow(BorrowingRule rule, List<BorrowingRule> rules) {
    return DataRow(
      cells: [
        DataCell(
          ItemTypeEditButton(
            rule: rule,
            existingRules: rules,
          ),
        ),
        DataCell(
          Row(
            children: [
              Icon(itemTypes[rule.type]),
              SizedBox(width: 10),
              Flexible(child: Text(rule.type)),
            ],
          ),
        ),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (rule.maxBorrowingCount == 0)
                DeleteButton(rule: rule)
              else
                DecreaseButton(rule: rule),
              Text(rule.maxBorrowingCount.toString()),
              IncreaseButton(rule: rule),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final borrowingRuleRepository = context.read<BorrowingRuleRepository>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleText('Borrowing Rules'),
        Expanded(
          child: StreamBuilder<List<BorrowingRule>>(
            stream: borrowingRuleRepository.borrowingRulesStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorContainer(error: snapshot.error.toString());
              }

              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final rules = snapshot.data!
                  .where((rule) => rule.createdAt != null)
                  .toList();
              rules.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

              return ListView(
                shrinkWrap: true,
                children: [
                  if (rules.isEmpty) ...[
                    EmptyListState(
                      message: "No borrowing rules configured yet...",
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: NewRuleButton(rules: rules),
                    ),
                  ] else
                    DataTable(
                      columns: [
                        DataColumn(
                          label: NewRuleButton(rules: rules, isIcon: true),
                        ),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Max Count'), numeric: true),
                      ],
                      rows: rules
                          .map((rule) => _buildRuleRow(rule, rules))
                          .toList(),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
