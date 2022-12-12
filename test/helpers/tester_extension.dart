import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension CustomTester on WidgetTester {
  Future selectDropdownOption(String label, String optionName) async {
    final typeInput = find.ancestor(
      of: find.text(label),
      matching: find.byType(DropdownButtonFormField<String>),
    );
    await tap(typeInput);
    await pumpAndSettle();

    final option = find.text(optionName).last;
    await tap(option);
    await pumpAndSettle();
  }

  Future enterTextByLabel(String label, String text) async {
    final nameInput = find.ancestor(
      of: find.text(label),
      matching: find.byType(TextFormField),
    );
    await enterText(nameInput, text);
  }
}
