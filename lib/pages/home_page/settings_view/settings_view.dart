import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/settings_view/borrowing_rules_setting/borrowing_rules_setting.dart';
import 'package:spare_parts/pages/home_page/settings_view/set_admins_button.dart';
import 'package:spare_parts/pages/home_page/settings_view/users_setting/users_setting.dart';
import 'package:spare_parts/widgets/custom_layout_builder.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int _navigationIndex = 0;

  double _getPadding(BuildContext context, LayoutType layout) {
    switch (layout) {
      case LayoutType.mobile:
        return 10;
      case LayoutType.tablet:
        return 40;
      case LayoutType.desktop:
        return 200;
    }
  }

  Widget _buildContent() {
    switch (_navigationIndex) {
      case 0:
        return SetAdminsButton();
      case 1:
        return BorrowingRulesSetting();
      case 2:
        return UsersSetting();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayoutBuilder(builder: (context, layout) {
      return Row(
        children: [
          NavigationRail(
            extended:
                layout == LayoutType.desktop || layout == LayoutType.tablet,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person),
                label: Text('General'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.waving_hand_outlined),
                selectedIcon: Icon(Icons.waving_hand),
                label: Text('Borrowing Rules'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.manage_accounts_outlined),
                selectedIcon: Icon(Icons.manage_accounts),
                label: Text('Users'),
              ),
            ],
            selectedIndex: _navigationIndex,
            onDestinationSelected: (index) {
              setState(() {
                _navigationIndex = index;
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: _getPadding(context, layout),
              ),
              child: _buildContent(),
            ),
          )
        ],
      );
    });
  }
}
