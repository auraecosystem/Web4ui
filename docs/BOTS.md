# Web4ui bot system

## Design

Web4ui uses a local, explicit registry of compiled-in Dart bots. Each bot implements `Web4Bot` and returns a structured `BotReport`. `BotRegistry` selects the built-in implementations based on `Bot/bots_config.json`.

Configuration controls which known bots are enabled; it does **not** import, download, or execute Dart code from a URL. Unknown IDs and malformed configuration are rejected. This keeps bot selection predictable and avoids remote-code-execution risks.

## Run

1. Install Flutter and Dart.
2. From the repository root, run `flutter pub get`.
3. Run `flutter test`.
4. Run `flutter analyze`.

## Add a bot

1. Create a class implementing `Web4Bot` in `lib/bots/`.
2. Give it a stable unique `id`, a user-facing `name`, and implement `run(String input)` returning a `BotReport`.
3. Register it in the default list in `lib/bots/bot_registry.dart`.
4. Add its ID and enabled state to `Bot/bots_config.json`.
5. Add tests covering successful output, invalid input, and error behavior.

The registry currently ships with the existing `ScriptAnalyzer` implementation, wrapped by `ScriptAnalyzerPlugin`. The analyzer's existing checks are retained: comment count, async/await usage, TODO/FIXME markers, and a basic long-function heuristic.

## Limitations

The analyzer is heuristic, not a Dart parser or security scanner. Its comment and long-function counts may be approximate. Configuration is read as a string by the caller; the current Flutter UI demonstrates local script analysis and does not fetch remote bot code.
