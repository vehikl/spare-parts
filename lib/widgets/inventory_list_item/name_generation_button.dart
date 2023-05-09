import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/services/repositories/repositories.dart';

class NameGenerationButton extends StatefulWidget {
  final Function(String) onGenerate;
  final String itemType;

  const NameGenerationButton(
      {super.key, required this.onGenerate, required this.itemType});

  @override
  State<NameGenerationButton> createState() => _NameGenerationButtonState();
}

class _NameGenerationButtonState extends State<NameGenerationButton> {
  final _generationStreamController = StreamController<String?>();

  @override
  void initState() {
    _generationStreamController.add('');
    super.initState();
  }

  Future<void> _generateName() async {
    _generationStreamController.add(null);
    final metaRepository = context.read<MetaRepository>();

    final itemNameIds = await metaRepository.getItemNameIds();
    final nameId = (itemNameIds[widget.itemType] ?? 0) + 1;
    final newName = '${widget.itemType} #$nameId';
    widget.onGenerate(newName);
    _generationStreamController.add(newName);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _generationStreamController.stream,
        builder: (context, snap) {
          return IconButton(
            onPressed: snap.hasData
                ? () {
                    _generateName();
                  }
                : null,
            icon: snap.hasData
                ? Icon(Icons.autorenew)
                : const CircularProgressIndicator(),
          );
        });
  }
}
