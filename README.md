# Vehikl Spare Parts

This application is an inventory tracker for the Greater Vehikl Team. Chairs, desks, monitors and much more all in one place.


## Development setup

### Requirements

- Flutter v3 [install here](https://docs.flutter.dev/get-started/install)
- Firebase Tools: `npm i -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`
- Optional (but recommended): VS Code or Android Studio for better tooling around Flutter development

### Setup

Similarly to npm scripts, Flutter uses `derry` to run custom scripts. All scripts are defined in the `pubspec.yaml` under `scripts`. Install derry globally: 
```
flutter pub global activate derry
```

#### Local

1. Start the Firebase emulators and seed data from `/emulator_data`:
```
firebase emulators:start --import ./emulator_data
```

2. Run the app:
```
flutter run -d <device>
``` 
or run it through your favourite IDE.

#### Production

If you want to run the production app, make sure you have access to the production Spare Parts Firebase project.

1. Authenticate with Firebase:
```
firebase login
```

2. Fetch Firebase configuration files (`google-services.json` and `flutter_options.dart`):
```
flutterfire configure
```

3. Run the app:
```
flutter run -d <device>
``` 
or run it through your favourite IDE.

### Testing

Before running the tests it is required to build mock classes with 
```
derry build-mocks
```

Run the tests:
```
flutter test
```

Generate coverage:
```
flutter test --coverage
```

### VS Code extensions

- [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
- [Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters)
- [Flutter Coverage](https://marketplace.visualstudio.com/items?itemName=Flutterando.flutter-coverage)

## Contributors

Coming Soon...
