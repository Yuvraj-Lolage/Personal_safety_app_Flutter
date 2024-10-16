// map_component.dart
import 'package:flutter/material.dart';

class MapComponent extends StatefulWidget {
  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[100],
      child: const Text('Map Component'),
    );
  }
}
