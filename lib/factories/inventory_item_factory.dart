import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/factories/factory.dart';

class InventoryItemFactory extends Factory<InventoryItem> {
  @override
  InventoryItem create({String? name, CustomUser? borrower}) {
    return InventoryItem(
      id: faker.guid.guid(),
      type: faker.company.suffix(),
      name: name ?? faker.company.name(),
      borrower: borrower
    );
  }
}
