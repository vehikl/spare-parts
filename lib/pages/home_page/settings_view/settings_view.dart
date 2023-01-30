import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/borrowing_rule.dart';
import 'package:spare_parts/pages/home_page/settings_view/set_admins_button.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/title_text.dart';

import '../../../services/firestore_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

    return Column(
      children: [
        TitleText('Settings'),
        SetAdminsButton(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Borrowing Rules'),
            StreamBuilder<List<BorrowingRule>>(
              stream: firestoreService.borrowingRulesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorContainer(error: snapshot.error.toString());
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final rules = snapshot.data!;

                if (rules.isEmpty) {
                  return EmptyListState(
                    message: "No borrowing rules configured yet...",
                  );
                }

                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await firestoreService.addBorrowingRule(BorrowingRule(
                          type: itemTypes.keys.first,
                          maxBorrowingCount: 1,
                        ));
                      },
                      child: Text('Add Rule'),
                    ),
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
                                DataCell(Text(rule.type)),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: rule.maxBorrowingCount == 1
                                            ? null
                                            : () async {
                                                rule.maxBorrowingCount--;
                                                await firestoreService
                                                    .updateBorrowingRule(rule);
                                              },
                                        icon: Icon(Icons.remove),
                                      ),
                                      Text(rule.maxBorrowingCount.toString()),
                                      IconButton(
                                        onPressed: () async {
                                          rule.maxBorrowingCount++;
                                          await firestoreService
                                              .updateBorrowingRule(rule);
                                        },
                                        icon: Icon(Icons.add),
                                      ),
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
        )
      ],
    );
  }
}
