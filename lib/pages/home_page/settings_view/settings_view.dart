import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/home_page/settings_view/borrowing_rules_setting/borrowing_rules_setting.dart';
import 'package:spare_parts/pages/home_page/settings_view/set_admins_button.dart';
import 'package:spare_parts/pages/home_page/settings_view/users_setting/users_setting.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/buttons/logout_button.dart';
import 'package:spare_parts/widgets/custom_layout_builder.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int _navigationIndex = 0;

  bool get isAdmin => context.read<UserRole>() == UserRole.admin;

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
    return CustomLayoutBuilder(
      builder: (context, layout) {
        if (!isAdmin) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'More settings coming soon ;)',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                LogoutButton(popOnSuccess: layout == LayoutType.desktop)
              ],
            ),
          );
        }

        return Row(
          children: [
            NavigationRail(
              extended:
                  layout == LayoutType.desktop || layout == LayoutType.tablet,
              elevation: 5,
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
                if (index == 3) {}

                setState(() {
                  _navigationIndex = index;
                });
              },
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LogoutButton(
                      iconOnly: layout == LayoutType.mobile,
                      popOnSuccess: layout == LayoutType.desktop,
                    ),
                  ),
                ),
              ),
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
      },
    );
  }
}
