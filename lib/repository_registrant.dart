import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/services/repositories/repositories.dart';

class RepositoryRegistrant extends StatelessWidget {
  final Widget child;
  final FirebaseFirestore firestore;
  final InventoryItemRepository? inventoryItemRepository;

  const RepositoryRegistrant({
    super.key,
    required this.child,
    required this.firestore,
    this.inventoryItemRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<InventoryItemRepository>(
            create: (context) =>
                inventoryItemRepository ?? InventoryItemRepository(firestore)),
        Provider<BorrowingRuleRepository>(
            create: (_) => BorrowingRuleRepository(firestore)),
        Provider<BorrowingRequestRepository>(
          create: (_) => BorrowingRequestRepository(firestore),
        ),
        Provider<MetaRepository>(create: (_) => MetaRepository(firestore)),
        Provider<UserRepository>(create: (_) => UserRepository(firestore)),
      ],
      child: child,
    );
  }
}
