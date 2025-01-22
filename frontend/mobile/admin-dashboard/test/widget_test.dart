import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin/main.dart';

void main() {
  testWidgets('Dashboard app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(AdminDashboard());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
