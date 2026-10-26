# Web4ui

Web4ui is a Flutter/Dart project with a local modular bot registry and a Script Analyzer bot.

## Getting started

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

## Bots

See [docs/BOTS.md](docs/BOTS.md) for the bot contract, registration model, configuration format, and instructions for adding a new bot.

Bot configuration only enables or disables implementations compiled into the app. It does not download or execute Dart source from a URL.

## VS Code

Install the Dart and Flutter extensions. Use **Terminal → Run Task** for dependency setup, formatting, static analysis, tests, and running the app. The repository's Flutter CI workflow runs analysis and tests on pushes and pull requests.
