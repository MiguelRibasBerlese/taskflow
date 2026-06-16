import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Descomente após executar `flutterfire configure` (gera firebase_options.dart):
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'firebase_config.dart';
import 'app/auth_gate.dart';

import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/category_provider.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/edit_task_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/about_screen.dart';
import 'screens/ibge/estados_screen.dart';

import 'utils/constants.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kFirebaseEnabled) {
    // Descomente após executar `flutterfire configure`:
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  }

  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        // AuthGate decide entre modo seguro (mock) e modo Firebase.
        home: const AuthGate(),
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.addTask: (_) => const AddTaskScreen(),
          AppRoutes.editTask: (_) => const EditTaskScreen(),
          AppRoutes.taskDetail: (_) => const TaskDetailScreen(),
          AppRoutes.categories: (_) => const CategoriesScreen(),
          AppRoutes.about: (_) => const AboutScreen(),
          AppRoutes.estados: (_) => const EstadosScreen(),
        },
      ),
    );
  }
}
