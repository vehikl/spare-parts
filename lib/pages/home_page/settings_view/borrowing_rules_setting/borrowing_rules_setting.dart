import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/borrowing_rule.dart';
import 'package:spare_parts/pages/home_page/settings_view/borrowing_rules_setting/item_type_edit_button.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/title_text.dart';

part 'decrease_button.dart';
part 'delete_button.dart';
part 'increase_button.dart';

class BorrowingRulesSetting extends StatelessWidget {
  const BorrowingRulesSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleText('Borrowing Rules'),
        StreamBuilder<List<BorrowingRule>>(
          stream: firestoreService.borrowingRulesStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorContainer(error: snapshot.error.toString());
            }

            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final rules =
                snapshot.data!.where((rule) => rule.createdAt != null).toList();
            rules.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

            return Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
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
                  ),
                ),
                if (rules.isEmpty)
                  EmptyListState(
                    message: "No borrowing rules configured yet...",
                  )
                else
                  DataTable(
                    columns: [
                      DataColumn(
                        label: Text(
                          'Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Max Count',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                    ],
                    rows: rules
                        .map(
                          (rule) => DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    ItemTypeEditButton(
                                      rule: rule,
                                      existingRules: rules,
                                    ),
                                    Flexible(child: Text(rule.type)),
                                  ],
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    if (rule.maxBorrowingCount == 1)
                                      DeleteButton(rule: rule)
                                    else
                                      DecreaseButton(rule: rule),
                                    Text(rule.maxBorrowingCount.toString()),
                                    IncreaseButton(rule: rule),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}