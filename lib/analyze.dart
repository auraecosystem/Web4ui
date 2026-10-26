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
}
