# Web4ui

Web4ui is a Dart/Flutter-oriented project with an explicitly registered bot framework.

## Requirements

- Flutter SDK with Dart 3.3 or newer
- Visual Studio Code with the Dart and Flutter extensions (optional)

## Setup and validation

Run these commands from the repository root:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
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

## Bot architecture

- `lib/src/bot.dart` defines the `Web4Bot`, `BotContext`, and `BotResult` contracts.
- `lib/src/bot_registry.dart` registers bots by unique ID, runs them, and selects enabled bots from JSON.
- `lib/bots/script_analyzer_plugin.dart` adapts the existing analyzer to the shared contract.
- `lib/bot_system.dart` exports the public API.
- `config/bots.json` is the sample configuration.
- `test/bot_registry_test.dart` covers registration, execution, unknown IDs, duplicate IDs, JSON configuration, and the analyzer adapter.

### Register another bot

1. Create a Dart class implementing `Web4Bot`.
2. Give it a stable unique `id`, a `name`, a `description`, and implement `run(BotContext)`.
3. Import the class and pass an instance to `BotRegistry([...])`.
4. Add its ID to `config/bots.json` with `"enabled": true`.

```dart
final registry = BotRegistry([
  ScriptAnalyzerPlugin(),
  MyCustomBot(),
]);
```

The registry intentionally does **not** download and execute Dart files from URLs. Flutter applications compile Dart code as part of the app build; remote configuration can select built-in bots, but adding executable bot code requires a reviewed application build or a separately designed, sandboxed service. Do not give plugins secrets or unrestricted capabilities.

## VS Code

Use **Terminal → Run Task** to run Flutter dependency setup, formatting, static analysis, and tests. Debug the app from `lib/main.dart` using the Flutter extension. Existing application files are retained; this framework is additive.
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
