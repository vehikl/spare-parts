import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/settings_view/borrowing_rules_setting/borrowing_rules_setting.dart';
import 'package:spare_parts/pages/home_page/settings_view/set_admins_button.dart';
import 'package:spare_parts/widgets/custom_layout_builder.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomLayoutBuilder(builder: (context, layout) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: layout == LayoutType.mobile
              ? 10
              : MediaQuery.of(context).size.width / 4,
        ),
        child: Column(
          children: [
            SetAdminsButton(),
            BorrowingRulesSetting(),
          ],
        ),
      );
    });
  }
}
