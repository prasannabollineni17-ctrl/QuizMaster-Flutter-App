import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/main.dart';

void main() {
  testWidgets('Smart Quiz app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartQuizApp());

    // Verify that the Quiz navigation tab exists
    expect(find.text('Quiz'), findsWidgets);
  });
}
