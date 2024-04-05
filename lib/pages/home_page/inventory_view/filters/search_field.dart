import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final void Function(String)? onChanged;
  final String value;
  final TextEditingController searchFieldController = TextEditingController();

  SearchField({
    super.key,
    this.value = '',
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    searchFieldController.text = value;

    return TextField(
      key: Key('search'),
      controller: searchFieldController,
      decoration: InputDecoration(
        hintText: 'Search',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
              searchFieldController.text.isEmpty ? Icons.search : Icons.clear),
          onPressed: () {
            onChanged?.call('');
            searchFieldController.clear();
          },
        ),
      ),
      onChanged: onChanged,
      enabled: onChanged != null,
    );
  }
}
