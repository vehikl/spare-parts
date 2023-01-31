import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/settings_view/borrowing_rules_setting/borrowing_rules_setting.dart';
import 'package:spare_parts/pages/home_page/settings_view/set_admins_button.dart';
import 'package:spare_parts/widgets/title_text.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleText('Settings'),
        SetAdminsButton(),
        BorrowingRulesSetting(),
      ],
    );
  }
}
