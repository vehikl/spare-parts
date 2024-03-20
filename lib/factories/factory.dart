import 'package:faker/faker.dart';

abstract class Factory<T> {
  final Faker faker = Faker();

  T create();

  List<T> createMany(int n) {
    return List.generate(n, (_) => create());
  }
}
