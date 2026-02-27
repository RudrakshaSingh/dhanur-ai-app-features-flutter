import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dhanur_ai_app_features_flutter/app/app_shell.dart';

void main() {
  testWidgets('AppShell switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppShell(
          screens: <Widget>[
            Center(child: Text('Live Tab')),
            Center(child: Text('Mic Tab')),
            Center(child: Text('Player Tab')),
          ],
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Live'),
            BottomNavigationBarItem(icon: Icon(Icons.radio), label: 'Mic'),
            BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: 'Player'),
          ],
        ),
      ),
    );

    expect(find.text('Live Tab'), findsOneWidget);
    expect(find.text('Mic Tab'), findsNothing);

    await tester.tap(find.text('Mic'));
    await tester.pump();

    expect(find.text('Mic Tab'), findsOneWidget);
    expect(find.text('Live Tab'), findsNothing);
  });
}
