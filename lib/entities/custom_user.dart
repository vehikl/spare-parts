import 'package:firebase_auth/firebase_auth.dart';

class CustomUser {
  final String uid;
  final String? name;
  final String? email;
  final String? photoURL;

  const CustomUser({
    required this.uid,
    this.name,
    this.email,
    this.photoURL,
  });

  CustomUser.fromFirestore(Map<String, dynamic> data)
      : uid = data['uid'],
        name = data['name'],
        email = data['email'],
        photoURL = data['photoURL'];

  CustomUser.fromUser(User user)
      : uid = user.uid,
        name = user.displayName,
        email = user.email,
        photoURL = user.photoURL;

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoURL': photoURL,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
