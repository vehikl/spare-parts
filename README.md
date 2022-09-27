# Vehikl Spare Parts

This application is an inventory tracker for the Greater Vehikl team. Chairs, desks, monitors and much more all in one place.


## Development setup

### Requirements

- Flutter v3 [here](https://docs.flutter.dev/get-started/install)
- Firebase Tools: `npm i -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`
- Optional (but recommended): VS Code or Android Studio for better tooling around Flutter development

### Setup

If you intend to only run the app locally, Firebase Simulators are coming soon. If you want to run the production app, make sure you have access to the production Spare Parts Firebase project.

1. Run `firebase login` and make sure your user has access to the Spare Parts firebase project.
2. Run `flutterfire configure` - this fetches Firebase configuration files (`google-services.json` and `flutter_options.dart`) for the specified project.
3. Use your IDE to run the app or do it through the terminal: `flutter run`. 

### Useful Commands

- `flutterfire configure` - fetches Firebase project configuration
- `flutter run` - runs the app on the selected device

### VS Code extensions

- [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
- [Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters)
- [Flutter Coverage](https://marketplace.visualstudio.com/items?itemName=Flutterando.flutter-coverage)