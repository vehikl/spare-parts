@JS('dymo.label.framework')
library dymo;

import 'package:js/js.dart';

@JS('init')
external void init();
// external void init(void Function(EnvironmentStatus status) callback);

Future<void> initAsync() async {
  // TODO: figure out how to make this work
  // var initInProgress = true;
  // init(allowInterop((_) => initInProgress = false));
  // await Future.doWhile(() => initInProgress);

  init();
  await Future.delayed(const Duration(seconds: 2));
}

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
