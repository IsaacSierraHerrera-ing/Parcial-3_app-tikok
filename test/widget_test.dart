// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:app_tiktok/auth_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Muestra el formulario de inicio de sesión', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(onRegister: () {}, onLoggedIn: () {}),
      ),
    );

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
  });
}
