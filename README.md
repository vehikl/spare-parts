# Vehikl Spare Parts
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-6-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

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

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://andreyden.github.io/"><img src="https://avatars.githubusercontent.com/u/25109066?v=4?s=100" width="100px;" alt="Andrii Denysenko"/><br /><sub><b>Andrii Denysenko</b></sub></a><br /><a href="https://github.com/vehikl/spare-parts/commits?author=ANDREYDEN" title="Code">💻</a> <a href="#design-ANDREYDEN" title="Design">🎨</a> <a href="#ideas-ANDREYDEN" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/vehikl/spare-parts/commits?author=ANDREYDEN" title="Tests">⚠️</a> <a href="https://github.com/vehikl/spare-parts/pulls?q=is%3Apr+reviewed-by%3AANDREYDEN" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/alisondraV"><img src="https://avatars.githubusercontent.com/u/56138100?v=4?s=100" width="100px;" alt="Alisa Vynohradova"/><br /><sub><b>Alisa Vynohradova</b></sub></a><br /><a href="https://github.com/vehikl/spare-parts/commits?author=alisondraV" title="Code">💻</a> <a href="#design-alisondraV" title="Design">🎨</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kgallego"><img src="https://avatars.githubusercontent.com/u/37840194?v=4?s=100" width="100px;" alt="Karen Gallego"/><br /><sub><b>Karen Gallego</b></sub></a><br /><a href="https://github.com/vehikl/spare-parts/commits?author=kgallego" title="Code">💻</a> <a href="#design-kgallego" title="Design">🎨</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/FrankyFrankFrank"><img src="https://avatars.githubusercontent.com/u/6907518?v=4?s=100" width="100px;" alt="Adam Frank"/><br /><sub><b>Adam Frank</b></sub></a><br /><a href="https://github.com/vehikl/spare-parts/commits?author=FrankyFrankFrank" title="Code">💻</a> <a href="#design-FrankyFrankFrank" title="Design">🎨</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.whitforddesign.ca/"><img src="https://avatars.githubusercontent.com/u/60898437?v=4?s=100" width="100px;" alt="whitfona"/><br /><sub><b>whitfona</b></sub></a><br /><a href="https://github.com/vehikl/spare-parts/commits?author=whitfona" title="Code">💻</a> <a href="#design-whitfona" title="Design">🎨</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/OleksandrLevinskyi"><img src="https://avatars.githubusercontent.com/u/72713236?v=4?s=100" width="100px;" alt="Oleksandr Levinskyi"/><br /><sub><b>Oleksandr Levinskyi</b></sub></a><br /><a href="https://github.com/vehikl/spare-parts/commits?author=OleksandrLevinskyi" title="Code">💻</a></td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td align="center" size="13px" colspan="7">
        <img src="https://raw.githubusercontent.com/all-contributors/all-contributors-cli/1b8533af435da9854653492b1327a23a4dbd0a10/assets/logo-small.svg">
          <a href="https://all-contributors.js.org/docs/en/bot/usage">Add your contributions</a>
        </img>
      </td>
    </tr>
  </tfoot>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->