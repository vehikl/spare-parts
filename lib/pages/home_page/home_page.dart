import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    _pageTitle = isAdmin ? 'Inventory' : 'My Items';
    super.initState();
  }

  void _handleSignOut() {
    final auth = context.read<FirebaseAuth>();
    auth.signOut();
  }

  void _handleSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            actions: [
              TextButton.icon(
                label: Text('Logout'),
                onPressed: _handleSignOut,
                icon: const Icon(Icons.logout),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
            ],
          ),
          body: Center(child: SettingsView()),
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
      _pageTitle = TabFactory.getPageTitles(isAdmin)[index];
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedBottomNavItemIndex = index;
    });
  }

  bool get isAdmin => context.read<UserRole>() == UserRole.admin;

  @override
  Widget build(BuildContext context) {
    return CustomLayoutBuilder(
      builder: (context, layout) {
        return Scaffold(
          floatingActionButtonLocation: layout == LayoutType.desktop
              ? FloatingActionButtonLocation.startFloat
              : null,
          appBar: AppBar(
            centerTitle: true,
            title: Text(_pageTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _handleScan,
                color: Theme.of(context).colorScheme.primary,
              ),
              if (layout == LayoutType.desktop && isAdmin)
                TextButton.icon(
                  label: Text('Settings'),
                  onPressed: _handleSettings,
                  icon: Icon(Icons.settings),
                ),
              TextButton.icon(
                label: Text('Logout'),
                onPressed: _handleSignOut,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          floatingActionButton: isAdmin ? AddInventoryItemButton() : null,
          body: layout == LayoutType.desktop
              ? SizedBox(
                  child: Row(
                    children: TabFactory.getDesktopPages(),
                  ),
                )
              : PageView(
                  controller: pageController,
                  onPageChanged: _onPageChanged,
                  children: TabFactory.getPages(isAdmin),
                ),
          bottomNavigationBar: layout == LayoutType.desktop
              ? null
              : BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  items: TabFactory.getBottomNavBarItems(isAdmin),
                  currentIndex: _selectedBottomNavItemIndex,
                  onTap: _onBottomNavItemTapped,
                ),
        );
      },
    );
  }
}
