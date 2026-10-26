import 'lib/script_analyzer_bot.dart';

/// Standalone Dart demo. The Flutter app entry point is lib/main.dart.
void main() {
  const sampleScript = '''
// TODO: replace this sample with a file input
Future<void> main() async {
  await doSomething();
}
''';

  ScriptAnalyzer(sampleScript).analyze();
}
