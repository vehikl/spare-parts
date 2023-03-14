import 'package:flutter/material.dart';
import 'package:spare_parts/widgets/title_text.dart';

class RefreshableTitle extends StatefulWidget {
  final Future Function() onRefresh;

  const RefreshableTitle({super.key, required this.onRefresh});

  @override
  State<RefreshableTitle> createState() => _RefreshableTitleState();
}

class _RefreshableTitleState extends State<RefreshableTitle> {
  bool refreshing = false;

  void refresh() async {
    setState(() {
      refreshing = true;
    });
    try {
      await widget.onRefresh();
    } finally {
      setState(() {
        refreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TitleText('Environment Status'),
        refreshing
            ? SizedBox.square(dimension: 20, child: CircularProgressIndicator())
            : IconButton(
                onPressed: refresh,
                icon: Icon(Icons.refresh),
              ),
      ],
    );
  }
}
