# Web4ui

Web4ui is currently a small Dart/Flutter project scaffold. The repository contains a Flutter UI entry point, script-analysis prototypes, JSON bot manifests, and editor/module configuration.

## Architecture

- `lib/main.dart` — Flutter UI and the current remote-configuration demo.
- `lib/script_analyzer_bot.dart` — basic source-text metrics and TODO/FIXME checks.
- `lib/bot_registry.dart` — explicit in-process bot registry and a sample metrics bot.
- `lib/analyze.dart` — command-line helper for reading a local bot manifest and reporting entries; it does not execute source files.
- `bots_config.json` and `Bot/bots_config.json` — example bot manifests. Keep these aligned when editing configuration.
- `.vscode/` — Dart/Flutter launch and task configuration.
- `pubspec.yaml` — Dart/Flutter package manifest.

## Bot execution model

Flutter does not provide general runtime imports for arbitrary Dart source downloaded from a URL. The remote loader in `lib/main.dart` is only a configuration-fetching demo: it logs configured URLs and does not execute the remote code. For executable features, implement a `Web4Bot` and register it with `BotRegistry`. Only register trusted code that ships with the app.

## Development

Install the Flutter SDK and the Dart/Flutter extensions for VS Code, then run:

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Use the VS Code task menu to run the same commands. The project has not yet been validated in a local Flutter SDK environment; run the checks above before release.
Web4ui is a Flutter/Dart project. The repository includes a local modular bot registry and a Script Analyzer bot.

## Getting started

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

## Bots

See [docs/BOTS.md](docs/BOTS.md) for the bot interface, safe registration model, configuration format, and instructions for adding a new bot.
