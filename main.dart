// bin/main.dart or main.dart

import 'package:script_analyzer_bot/analyzer.dart';

void main() {
  const sampleScript = '''
  // This is a comment
  void main() async {
    await doSomething();
    // TODO: Refactor this function
  }
  ''';

  final analyzer = ScriptAnalyzer(sampleScript);
  analyzer.analyze();
}
