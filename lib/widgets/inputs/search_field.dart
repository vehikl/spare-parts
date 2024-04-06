import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final void Function(String)? onChanged;

  const SearchField({
    super.key,
    required this.onChanged,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _searchFieldController = TextEditingController();
  IconData _suffixIcon = Icons.search;

  @override
  void initState() {
    _searchFieldController.addListener(() {
      widget.onChanged?.call(_searchFieldController.text);
      setState(() {
        _suffixIcon =
            _searchFieldController.text.isEmpty ? Icons.search : Icons.clear;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: Key('search'),
      controller: _searchFieldController,
      decoration: InputDecoration(
        hintText: 'Search',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        suffixIcon: IconButton(
          icon: Icon(_suffixIcon),
          onPressed: _searchFieldController.clear,
        ),
      ),
      enabled: widget.onChanged != null,
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'SearchField',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SearchField(
          onChanged: (value) => print('New search value: $value'),
        ),
      ),
    ),
  );
}
