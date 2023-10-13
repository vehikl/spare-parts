import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/inventory_item.dart';

void main() {
  group('InvetnoryItem', () {
    test('returns short name for printing', () {
      final item = InventoryItem(
        id: '123',
        type: 'Laptop',
        name: 'MacBook Pro',
      );

      expect(item.nameForPrinting, 'MacBook Pro');
    });

    test('returns long name for printing', () {
      final item = InventoryItem(
        id: '123',
        type: 'Laptop',
        name: 'This name has over 19 characters',
      );

      expect(item.nameForPrinting, 'This nam...aracters');
    });
  });
}