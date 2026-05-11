import 'package:flutter_test/flutter_test.dart';
import 'package:tennis_swing_analyzer/main.dart';

void main() {
  testWidgets('App should render without crashing', (tester) async {
    await tester.pumpWidget(const TennisSwingAnalyzerApp());
    // Verify the app title is displayed in the AppBar
    expect(find.text('Tennis Swing Analyzer'), findsOneWidget);
  });
}
