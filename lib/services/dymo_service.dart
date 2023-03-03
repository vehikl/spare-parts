@JS('dymo.label.framework')
library dymo;

import 'package:js/js.dart';

@JS('init')
external void init();

@JS('checkEnvironment')
external EnvironmentStatus checkEnvironment();

@JS('getPrinters')
external List<Printer> getPrinters();

@JS('openLabelXml')
external Label openLabelXml(String xml);

@JS()
@anonymous
class EnvironmentStatus {
  bool isBrowserSupported = false;
  bool isFrameworkInstalled = false;
  bool isWebServicePresent = false;
}

@JS()
@anonymous
class Printer {
  String name = '';
}

@JS()
@anonymous
class Label {
  @JS('print')
  external void print(String printerName);
}
