import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:taskflow/main.dart';
import 'package:taskflow/providers/auth_provider.dart';
import 'package:taskflow/providers/task_provider.dart';
import 'package:taskflow/providers/category_provider.dart';
import 'package:taskflow/screens/login_screen.dart';
import 'package:taskflow/utils/constants.dart';

void main() {
  testWidgets('App inicia na tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle();

    // Verifica que a tela de login está sendo exibida
    expect(find.text(AppStrings.appName), findsWidgets);
    expect(find.text(AppStrings.login), findsOneWidget);
  });

  testWidgets('Login com credencial inválida exibe erro',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Tenta submeter sem preencher campos
    await tester.tap(find.text(AppStrings.login));
    await tester.pumpAndSettle();

    // Deve exibir mensagem de campo obrigatório
    expect(find.text(AppStrings.required), findsWidgets);
  });

  testWidgets('Campos de email e senha estão presentes na tela de login',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.email), findsOneWidget);
    expect(find.text(AppStrings.password), findsOneWidget);
    expect(find.text(AppStrings.login), findsOneWidget);
  });
}
