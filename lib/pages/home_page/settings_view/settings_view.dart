import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/settings_view/borrowing_rules_setting/borrowing_rules_setting.dart';
import 'package:spare_parts/pages/home_page/settings_view/set_admins_button.dart';
import 'package:spare_parts/pages/home_page/settings_view/users_setting/users_setting.dart';
import 'package:spare_parts/widgets/custom_layout_builder.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  double _getPadding(BuildContext context, LayoutType layout) {
    switch (layout) {
      case LayoutType.mobile:
        return 10;
      case LayoutType.tablet:
        return MediaQuery.of(context).size.width / 6;
      case LayoutType.desktop:
        return MediaQuery.of(context).size.width / 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayoutBuilder(builder: (context, layout) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: _getPadding(context, layout),
        ),
        // TODO: reorder into multiple tabs
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView(
            shrinkWrap: true,
            children: [
              SetAdminsButton(),
              ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: true),
                child: BorrowingRulesSetting(),
              ),
              ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: true),
                child: UsersSetting(),
              ),
            ],
          ),
        ),
      );
    });
  }
}
