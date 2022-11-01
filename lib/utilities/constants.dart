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

MaterialColor kVehiklMaterialColor = MaterialColor(0xFFDD5F13, colorCodes);

Map<String, IconData> itemTypes = {
  'Desk': Icons.desk,
  'Chair': Icons.chair,
  'Monitor': Icons.monitor,
  'Laptop': Icons.laptop,
  'Dongle': Icons.electrical_services,
  'Power Cord': Icons.electrical_services,
  'Keyboard': Icons.keyboard,
  'Mouse or Trackpad': Icons.mouse,
  'Webcam': Icons.photo_camera,
  'Stand Up Desk': Icons.desk,
  'USB-C extender cable': Icons.electrical_services,
  'Monitor Arm': Icons.precision_manufacturing,
  'SnowBall Mic': Icons.mic,
  'Laptop Stand': Icons.laptop,
  'HDMI Cable': Icons.electrical_services,
  'Projector': Icons.videocam,
  '100" Screen': Icons.monitor,
  'Webcam Stand': Icons.precision_manufacturing,
  'London Desk': Icons.desk,
  'Ethernet Cable': Icons.electrical_services,
  "Hamilton's Network Router": Icons.router,
  'Office filer': Icons.folder,
  'HP Printer/scanner': Icons.print,
  'Other': Icons.miscellaneous_services,
};

enum UserRole { user, admin }

const TextStyle kEmptyListStyle = TextStyle(
  fontSize: 24,
  color: Colors.grey,
);

final kBorderRadius = BorderRadius.circular(5);
