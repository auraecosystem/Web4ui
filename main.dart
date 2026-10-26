import 'package:web4ui/bots/bot_registry.dart';

/// Small standalone demo; the Flutter app starts from lib/main.dart.
Future<void> main() async {
  final registry = BotRegistry();
  registry.configure(
    '{"bots":[{"id":"script-analyzer","enabled":true}]}',
  );
  final reports = await registry.runAll(
    '// TODO: replace this sample\nvoid main() async { await work(); }',
  );
  for (final report in reports) {
    print(report.title);
    for (final finding in report.findings) {
      print(finding);
    }
  }
}
