// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/data_provider.dart';
import 'package:frontend/providers/theme_provider.dart';

void main() {
  testWidgets('Cardiac login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const CardiacApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Cardiac'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
