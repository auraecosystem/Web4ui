import 'package:flutter_test/flutter_test.dart';
import 'package:web4ui/main.dart';

void main() {
  testWidgets('workbench runs the configured script analyzer', (tester) async {
    await tester.pumpWidget(const Web4uiApp());

    expect(find.text('Web4ui Script Analyzer'), findsOneWidget);
    await tester.tap(find.text('Analyze script'));
    await tester.pumpAndSettle();

    expect(find.text('Script analysis'), findsOneWidget);
    expect(find.text('TODO/FIXME markers: 1'), findsOneWidget);
  });
}
