import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medlink/shared/widgets/section_header.dart';

void main() {
  testWidgets('SectionHeader renders title and action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SectionHeader(
            title: 'Top Rated Doctors',
            actionLabel: 'See all',
          ),
        ),
      ),
    );

    expect(find.text('Top Rated Doctors'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
  });
}
