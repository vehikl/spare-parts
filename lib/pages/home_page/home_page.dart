import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/borrowed_items_view.dart';
import 'package:spare_parts/pages/home_page/inventory_view/inventory_view.dart';
import 'package:spare_parts/pages/home_page/settings_view/settings_view.dart';
import 'package:spare_parts/pages/item_page.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/add_inventory_item_button.dart';
import 'package:spare_parts/widgets/custom_layout_builder.dart';
import 'package:spare_parts/widgets/title_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedBottomNavItemIndex = 0;
  String _pageTitle = 'Spare Parts';
  final PageController pageController = PageController();

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
    final firestore = context.read<FirestoreService>();
    final userRole = context.read<UserRole>();

    var scanning = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Mobile Scanner')),
          body: MobileScanner(
            fit: BoxFit.contain,
            onDetect: (capture) async {
              if (!scanning) return;

              final List<Barcode> barcodes = capture.barcodes;

              if (barcodes.isNotEmpty) {
                try {
                  scanning = false;
                  final barcodeValue = barcodes.first.rawValue;
                  print("IDDD: $barcodeValue");

                  final itemRef = await firestore
                      .getItemDocumentReference(barcodeValue)
                      .get();

                  if (itemRef.exists) {
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Provider.value(
                          value: userRole,
                          child: ItemPage(
                            item: InventoryItem.fromFirestore(itemRef
                                as DocumentSnapshot<Map<String, dynamic>>),
                          ),
                        ),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Invalid QR Code: $barcodeValue'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ));
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('An error occured while scanning QR Code'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ));
                }
              }
            },
          ),
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
      switch (index) {
        case 1:
          _pageTitle = 'Borrowed Items';
          break;
        case 2:
          _pageTitle = 'Settings';
          break;
        default:
          _pageTitle = 'Spare Parts';
      }
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
              if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.android)
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
          floatingActionButton: AddInventoryItemButton(),
          body: layout == LayoutType.desktop
              ? SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: const [
                            TitleText('Inventory'),
                            Expanded(child: InventoryView()),
                          ],
                        ),
                      ),
                      VerticalDivider(),
                      Expanded(
                        child: Column(
                          children: const [
                            TitleText('Borrowed Items'),
                            Expanded(child: BorrowedItemsView())
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : PageView(
                  controller: pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    InventoryView(),
                    BorrowedItemsView(),
                    if (isAdmin) SettingsView()
                  ],
                ),
          bottomNavigationBar: layout == LayoutType.desktop
              ? null
              : BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Inventory',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.backpack_outlined),
                      activeIcon: Icon(Icons.backpack),
                      label: 'Borrowed Items',
                    ),
                    if (isAdmin)
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings_outlined),
                        activeIcon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                  ],
                  currentIndex: _selectedBottomNavItemIndex,
                  onTap: _onBottomNavItemTapped,
                ),
        );
      },
    );
  }
}
