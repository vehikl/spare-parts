import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;

  const SearchField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final searchFieldController = TextEditingController(text: value);

    return TextField(
      controller: searchFieldController,
      decoration: InputDecoration(
        hintText: 'Search',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        suffixIcon: IconButton(
          icon: Icon(value.isEmpty ? Icons.search : Icons.clear),
          onPressed: () {
            onChanged('');
            searchFieldController.clear();
          },
        ),
      ),
      onChanged: onChanged,
    );
  }
}
