import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:duolingo_clone/main.dart';

void main() {
  testWidgets('Main layout shows the custom bottom navigation bar', (WidgetTester tester) async {
    await tester.pumpWidget(const DuolingoCloneApp());

    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.card_travel_rounded), findsOneWidget);
    expect(find.byIcon(Icons.shield_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
  });
}
