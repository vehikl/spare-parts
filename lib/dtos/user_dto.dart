import 'package:spare_parts/utilities/constants.dart';

class UserDto {
  final String id;
  final String name;
  final String? photoUrl;
  final UserRole role;

  UserDto({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.role,
  });

  UserDto.fromJson(dynamic data)
      : id = data['id'],
        name = data['name'],
        photoUrl = data['photoUrl'],
        role = data['role'] == 'admin' ? UserRole.admin : UserRole.user;
}
