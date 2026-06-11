import 'package:flutter_test/flutter_test.dart';
import 'package:tennis_swing_analyzer/main.dart';

void main() {
  testWidgets('App should render without crashing', (tester) async {
    await tester.pumpWidget(const TennisSwingAnalyzerApp());

    expect(find.text('Tennis Swing Analyzer'), findsOneWidget);
  });
}
