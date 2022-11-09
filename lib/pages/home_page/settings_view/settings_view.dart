import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/settings_view/set_admins_button.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 10),
        SetAdminsButton()
      ],
    );
  }
}
