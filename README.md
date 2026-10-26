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
