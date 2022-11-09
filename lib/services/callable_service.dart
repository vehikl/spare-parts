import 'package:cloud_functions/cloud_functions.dart';
import 'package:spare_parts/dtos/user_dto.dart';

class CallableService {
  final HttpsCallable _getUsers =
      FirebaseFunctions.instance.httpsCallable('getUsers');

  final HttpsCallable _setAdmins =
      FirebaseFunctions.instance.httpsCallable('setAdmins');

  Future<List<UserDto>> getUsers() async {
    final response = await _getUsers.call();

    return (response.data as List<dynamic>)
        .map((u) => UserDto.fromJson(u))
        .toList();
  }

  Future setAdmins(List<String> uids) async {
    await _setAdmins.call({
      'uids': uids
    });
  }
}
