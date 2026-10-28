import 'package:flutter_test/flutter_test.dart';
import 'package:web4ui/bot_registry.dart';

void main() {
  group('BotRegistry', () {
    test('registers and runs a bot', () async {
      final registry = BotRegistry()..register(ScriptMetricsBot());

      final report = await registry.run(
        'script-metrics',
        'void main() async {\n  // TODO: improve\n  await work();\n}',
      );

      expect(report.botId, 'script-metrics');
      expect(report.summary, contains('4 lines'));
      expect(report.summary, contains('1 TODO/FIXME marker(s)'));
      expect(report.findings, hasLength(1));
    });

    test('rejects duplicate bot ids', () {
      final registry = BotRegistry()..register(ScriptMetricsBot());

      expect(
        () => registry.register(ScriptMetricsBot()),
        throwsA(isA<StateError>()),
      );
    });

    test('reports unknown bot ids', () {
      final registry = BotRegistry();

      expect(
        () => registry.run('missing', ''),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects duplicate bot IDs in configuration', () {
      final registry = BotRegistry();
      expect(
        () => registry.configure(
          '{"bots":[{"id":"script-analyzer"},{"id":"script-analyzer"}]}',
        ),
        throwsFormatException,
      );
    });
  });
}
