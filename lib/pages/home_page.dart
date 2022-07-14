import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/models/inventory_item.dart';
import 'package:spare_parts/widgets/inventory_item_form.dart';
import '../widgets/inventory_list_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  handleSignOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirebaseFirestore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(onPressed: handleSignOut, icon: const Icon(Icons.logout))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return const InventoryItemForm(
                formState: InventoryFormState.add,
              );
            },
          );
        },
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: firestore.collection('items').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.error == null) {
              final items = (snapshot.data?.docs ?? [])
                  .map(InventoryItem.fromFirestore)
                  .toList();

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  return InventoryListItem(item: item);
                },
              );
            } else {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.red,
                ),
                padding: const EdgeInsets.all(16),
                child: Text(snapshot.error.toString()),
              );
            }
          },
        ),
      ),
    );
  }
}
