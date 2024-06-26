import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showError({required BuildContext context, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error),
  );
}

void showSuccess({required BuildContext context, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.green),
  );
}

Future configureEmulators() async {
  const useEmulators = bool.fromEnvironment('USE_EMULATORS');
  log("Talking to Firebase ${useEmulators ? 'via EMULATORS' : 'in PRODUCTION'}");
  if (useEmulators) {
    try {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    } on Exception catch (e) {
      if ((e as dynamic).code != 'emulator-config-failed') rethrow;
      log(e.toString());
    }
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }
}

String formatDate(DateTime dateTime, {bool withTime = true}) {
  var dateTimeFormat = DateFormat.yMMMMd();
  if (withTime) {
    dateTimeFormat = dateTimeFormat.add_jm();
  }
  return dateTimeFormat.format(dateTime);
}

String stringIdentity(dynamic value) => value.toString();
