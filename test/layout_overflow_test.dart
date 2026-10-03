import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poshiva/screens/auth/account_created.dart';
import 'package:poshiva/screens/auth/login.dart';
import 'package:poshiva/screens/auth/register.dart';
import 'package:poshiva/screens/onboarding/onboarding_1.dart';
import 'package:poshiva/screens/onboarding/onboarding_2.dart';
import 'package:poshiva/screens/onboarding/onboarding_3.dart';

Future<void> pumpScreen(
  WidgetTester tester,
  Widget child,
  Size size,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump();
}

void main() {
  final small = const Size(320, 568);
  final large = const Size(414, 896);

  testWidgets('Onboarding 1 has no overflow on a small screen', (tester) async {
    await pumpScreen(tester, const Onboarding1Screen(), small);
    expect(tester.takeException(), isNull);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Onboarding 1 renders on a large screen', (tester) async {
    await pumpScreen(tester, const Onboarding1Screen(), large);
    expect(tester.takeException(), isNull);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Onboarding 2 has no overflow on a small screen', (tester) async {
    await pumpScreen(tester, const Onboarding2Screen(), small);
    expect(tester.takeException(), isNull);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Onboarding 3 has no overflow on a small screen', (tester) async {
    await pumpScreen(tester, const Onboarding3Screen(), small);
    expect(tester.takeException(), isNull);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Login has no overflow on a small screen', (tester) async {
    await pumpScreen(tester, const LoginScreen(), small);
    expect(tester.takeException(), isNull);
    expect(find.text('Create New Account'), findsOneWidget);
  });

  testWidgets('Account created has no overflow on a small screen',
      (tester) async {
    await pumpScreen(tester, const AccountCreatedScreen(), small);
    expect(tester.takeException(), isNull);
    expect(find.text('Go To Login'), findsOneWidget);
  });

  testWidgets('Register has no overflow on a small screen', (tester) async {
    await pumpScreen(tester, const RegisterScreen(), small);
    expect(tester.takeException(), isNull);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
