import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/home_page/settings_view/settings_view.dart';
import 'package:spare_parts/pages/home_page/tab_factory.dart';
import 'package:spare_parts/pages/qr_scan_page.dart';
import 'package:spare_parts/services/repositories/inventory_item_repository.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/add_inventory_item_button.dart';
import 'package:spare_parts/widgets/custom_layout_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedBottomNavItemIndex = 0;
  late String _pageTitle;
  final PageController pageController = PageController();
  late final TabFactory tabFactory;

  bool get isAdmin => context.read<UserRole>() == UserRole.admin;

  @override
  void initState() {
    _pageTitle = isAdmin ? 'Inventory' : 'My Items';
    tabFactory = TabFactory(isAdmin: isAdmin, isDesktop: false);
    super.initState();
  }

  void _handleSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: Center(
            child: Provider.value(
              value: context.read<UserRole>(),
              child: SettingsView(),
            ),
          ),
        ),
      ),
    );
  }

  void _handleScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            Provider.value(value: context.read<UserRole>()),
            Provider.value(value: context.read<InventoryItemRepository>()),
          ],
          child: QRScanPage(),
        ),
      ),
    );
  }

  void _onBottomNavItemTapped(int index) {
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );

    setState(() {
      _selectedBottomNavItemIndex = index;
      _pageTitle = tabFactory.getPageTitles()[index];
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedBottomNavItemIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayoutBuilder(
      builder: (context, layout) {
        final isDesktop = layout == LayoutType.desktop;
        tabFactory.isDesktop = isDesktop;

        return Scaffold(
          floatingActionButtonLocation:
              isDesktop ? FloatingActionButtonLocation.startFloat : null,
          appBar: AppBar(
            centerTitle: true,
            title: Text(isDesktop ? 'Spare Parts' : _pageTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _handleScan,
                color: Theme.of(context).colorScheme.primary,
              ),
              if (isDesktop)
                TextButton.icon(
                  label: Text('Settings'),
                  onPressed: _handleSettings,
                  icon: Icon(Icons.settings),
                ),
            ],
          ),
          floatingActionButton: isAdmin ? AddInventoryItemButton() : null,
          body: isDesktop
              ? SizedBox(
                  child: Row(children: tabFactory.getDesktopPages()),
                )
              : PageView(
                  controller: pageController,
                  onPageChanged: _onPageChanged,
                  children: tabFactory.getPages(),
                ),
          bottomNavigationBar: isDesktop
              ? null
              : BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  items: tabFactory.getBottomNavBarItems(),
                  currentIndex: _selectedBottomNavItemIndex,
                  onTap: _onBottomNavItemTapped,
                ),
        );
      },
    );
  }
}
