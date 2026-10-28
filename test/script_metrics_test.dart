import 'package:flutter_test/flutter_test.dart';
import 'package:web4ui/script_metrics.dart';

void main() {
  group('ScriptMetrics.fromSource', () {
    test('returns zero lines for an empty source', () {
      final metrics = ScriptMetrics.fromSource('');

      expect(metrics.characterCount, 0);
      expect(metrics.lineCount, 0);
      expect(metrics.nonEmptyLineCount, 0);
      expect(metrics.hasActionItems, isFalse);
    });

    test('counts lines and ignores whitespace-only lines as non-empty', () {
      final metrics = ScriptMetrics.fromSource('void main() {\n  \n}\n');

      expect(metrics.characterCount, 20);
      expect(metrics.lineCount, 4);
      expect(metrics.nonEmptyLineCount, 2);
    });

    test('counts TODO and FIXME markers without case sensitivity', () {
      final metrics = ScriptMetrics.fromSource(
        '// TODO: handle input\n// fixme: validate output\n// todo: add test',
      );

      expect(metrics.todoCount, 2);
      expect(metrics.fixmeCount, 1);
      expect(metrics.hasActionItems, isTrue);
    });
  });
}
