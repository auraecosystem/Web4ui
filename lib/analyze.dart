import 'dart:io';

import 'script_analyzer_bot.dart';

/// Analyze a script file from the command line.
///
/// Usage: dart run lib/analyze.dart path/to/script.dart
Future<void> main(List<String> args) async {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run lib/analyze.dart <script-file>');
    exitCode = 64;
    return;
  }

  final file = File(args.single);
  if (!await file.exists()) {
    stderr.writeln('File not found: ${file.path}');
    exitCode = 66;
    return;
  }

  final script = await file.readAsString();
  ScriptAnalyzer(script).analyze();
class BotLoader {
  /// Reads a local JSON manifest and reports the configured bot entries.
  ///
  /// This intentionally does not execute Dart files from disk. Dart/Flutter
  /// applications should register executable bot implementations in-process.
  Future<void> loadBots(String configFilePath) async {
    final file = File(configFilePath);
    if (!await file.exists()) {
      stderr.writeln('Config file not found: $configFilePath');
      return;
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(await file.readAsString());
    } on FormatException catch (error) {
      stderr.writeln('Invalid bot configuration: $error');
      return;
    }

    if (decoded is! Map<String, dynamic> || decoded['bots'] is! List) {
      stderr.writeln('Invalid bot configuration: expected a "bots" array.');
      return;
    }

    for (final entry in decoded['bots'] as List) {
      if (entry is! Map<String, dynamic>) {
        stderr.writeln('Skipping malformed bot entry: $entry');
        continue;
      }
      final name = entry['name'];
      final path = entry['path'];
      if (name is String && path is String) {
        stdout.writeln('Configured bot: $name ($path)');
      } else {
        stderr.writeln('Skipping bot entry without string name/path: $entry');
      }
    }
  }
}

int countComments(String script) {
  final pattern = RegExp(r'//.*?$|/\*[\s\S]*?\*/', multiLine: true);
  return pattern.allMatches(script).length;
}

bool usesAsyncAwait(String script) =>
    RegExp(r'\basync\b').hasMatch(script) &&
    RegExp(r'\bawait\b').hasMatch(script);

void analyzeScript(String script) {
  stdout.writeln('Comments found: ${countComments(script)}');
  stdout.writeln('Uses async/await: ${usesAsyncAwait(script)}');
}

Future<void> main() async {
  await BotLoader().loadBots('Bot/bots_config.json');
}
