import 'package:firebase_auth/firebase_auth.dart';

class CustomUser {
  final String uid;
  final String? name;
  final String? photoURL;

  const CustomUser({
    required this.uid,
    this.name,
    this.photoURL,
  });

  CustomUser.fromFirestore(Map<String, dynamic> data)
      : uid = data['uid'],
        name = data['name'],
        photoURL = data['photoURL'];

  CustomUser.fromUser(User user)
      : uid = user.uid,
        name = user.displayName,
        photoURL = user.photoURL;

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'photoURL': photoURL,
    };
  }
}
