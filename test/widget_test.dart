import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/main.dart';

void main() {
  testWidgets('PawCare App renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PawCareApp());
    await tester.pump();

    // Verify app shell and core UI elements exist
    expect(find.byType(PawCareApp), findsOneWidget);
    expect(find.textContaining('Aygen'), findsWidgets);
  });
}
