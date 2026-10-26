import 'package:flutter_test/flutter_test.dart';
import 'package:web4ui/bots/bot_registry.dart';

void main() {
  group('BotRegistry', () {
    test('runs the built-in script analyzer', () async {
      final registry = BotRegistry();
      registry.configure(
        '{"bots":[{"id":"script-analyzer","enabled":true}]}',
      );

      final reports = await registry.runAll(
        '// TODO: check\nvoid main() async { await work(); }',
      );
      expect(reports, hasLength(1));
      expect(reports.single.botId, 'script-analyzer');
      expect(reports.single.findings, contains('TODO/FIXME markers: 1'));
      expect(reports.single.findings, contains('Uses async/await: true'));
    });

    test('can disable a known bot', () {
      final registry = BotRegistry();
      registry.configure(
        '{"bots":[{"id":"script-analyzer","enabled":false}]}',
      );
      expect(registry.activeBots, isEmpty);
    });

    test('rejects unknown bot IDs instead of loading arbitrary code', () {
      final registry = BotRegistry();
      expect(
        () => registry.configure('{"bots":[{"id":"remote-code"}]}'),
        throwsFormatException,
      );
    });

    test('rejects malformed configuration shapes', () {
      final registry = BotRegistry();
      expect(() => registry.configure('[]'), throwsFormatException);
      expect(() => registry.configure('{"bots":{}}'), throwsFormatException);
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
