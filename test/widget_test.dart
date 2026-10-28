import 'package:flutter_test/flutter_test.dart';
import 'package:web4ui/main.dart';

void main() {
  testWidgets('workbench renders and runs the script analyzer', (tester) async {
    await tester.pumpWidget(const Web4uiApp());

    expect(find.text('Web4ui Bot Workbench'), findsOneWidget);
    expect(find.text('Script Analyzer'), findsOneWidget);

    await tester.tap(find.text('Analyze script'));
    await tester.pumpAndSettle();

    expect(find.text('Analysis report'), findsOneWidget);
    expect(find.textContaining('commentCount:'), findsOneWidget);
  });
}
