import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Repository<TRepository> {
  WriteBatch? batch;

  Repository({ this.batch });

  CollectionReference<Map<String, dynamic>> get collection;

  TRepository useBatch(WriteBatch batch) {
    return Repository(batch: batch);
  }

  FutureOr<String> add(Map<String, dynamic> item) async {
    if (batch != null) {
      final docRef = collection.doc();
      batch!.set(docRef, item);
      return docRef.id;
    }

    final docRef = await collection.add(item);
    return docRef.id;
  }
}