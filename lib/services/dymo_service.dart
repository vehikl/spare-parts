@JS('dymo.label.framework')
library dymo;

import 'package:js/js.dart';

@JS('init')
external void init();

@JS('checkEnvironment')
external EnvironmentStatus checkEnvironment();

@JS()
@anonymous
class EnvironmentStatus {
  bool isBrowserSupported = false;
  bool isFrameworkInstalled = false;
  bool isWebServicePresent = false;
}
