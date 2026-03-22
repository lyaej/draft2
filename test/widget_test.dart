import 'package:flutter_test/flutter_test.dart';
import 'package:tagalook/main.dart';

void main() {
  testWidgets('TagaLook smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TagaLookApp());
  });
}