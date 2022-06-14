import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/inventory_list_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.firestore}) : super(key: key);

  final FirebaseFirestore firestore;

  handleSignOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(onPressed: handleSignOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: firestore.collection('Items').get(),
          builder: (context, snapshot) {
            if (snapshot.error == null) {
              print(snapshot);
              final items = (snapshot.data?.docs ?? [])
                  .map((doc) => {'id': doc.id, ...doc.data()})
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
