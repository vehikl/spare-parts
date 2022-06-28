import 'package:flutter/material.dart';

Color kVehiklOrange = Color(0xFFDD5F13);

Map<int, Color> colorCodes = {
  50: Color.fromRGBO(221, 95, 19, .1),
  100: Color.fromRGBO(221, 95, 19, .2),
  200: Color.fromRGBO(221, 95, 19, .3),
  300: Color.fromRGBO(221, 95, 19, .4),
  400: Color.fromRGBO(221, 95, 19, .5),
  500: Color.fromRGBO(221, 95, 19, .6),
  600: Color.fromRGBO(221, 95, 19, .7),
  700: Color.fromRGBO(221, 95, 19, .8),
  800: Color.fromRGBO(221, 95, 19, .9),
  900: Color.fromRGBO(221, 95, 19, 1),
};

MaterialColor kVehiklMaterialColor = new MaterialColor(0xFFDD5F13, colorCodes);

Map<String, IconData> inventoryItems = {
  "Chair": Icons.chair,
  "Desk": Icons.desk,
  "Monitor": Icons.monitor,
  "Laptop": Icons.laptop
};
