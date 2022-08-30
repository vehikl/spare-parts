import 'package:flutter/material.dart';
import 'package:spare_parts/utilities/constants.dart';

class EmptyListState extends StatelessWidget {
  final String message;

  const EmptyListState({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: kEmptyListStyle,
      ),
    );
  }
}
