import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  handleSignOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(onPressed: handleSignOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection('Items').get(),
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
                  return ListTile(
                    title: Text(item['id']),
                  );
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
