import 'package:flutter_test/flutter_test.dart';
import 'package:web4ui/main.dart';

void main() {
  testWidgets('workspace renders and runs the local script analyzer',
      (tester) async {
    await tester.pumpWidget(const Web4uiApp());

    expect(find.text('script-analyzer'), findsWidgets);
    expect(find.text('Script workspace'), findsOneWidget);
    expect(find.text('Run analysis'), findsOneWidget);
    expect(find.text('Lines'), findsOneWidget);
    expect(find.text('TODO'), findsOneWidget);

    await tester.tap(find.text('Run analysis'));
    await tester.pumpAndSettle();

    expect(find.text('Analysis reports'), findsOneWidget);
    expect(find.textContaining('Comments found:'), findsOneWidget);
  });
}
