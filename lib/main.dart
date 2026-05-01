import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; 
import 'screen/login_screen/login.dart';
import 'screen/main_wrapper.dart';
import 'screen/settings_screen/settings.dart';
import 'screen/insights_screen/insights.dart';
import 'screen/task_list_screen/task_list.dart';
import 'screen/edit_profile_screen/edit_profile.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initializes Firebase for your app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();

  // Check if user is already logged in for session persistence
  final currentUser = FirebaseAuth.instance.currentUser;
  final String initialRoute = currentUser != null ? '/home' : '/';

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final themeService = ThemeService();
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeService.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            fontFamily: 'Inter',
            colorSchemeSeed: const Color(0xFF9D39F5),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            fontFamily: 'Inter',
            scaffoldBackgroundColor: const Color(0xFF0A0E21),
          ),
          initialRoute: initialRoute,
          routes: {
            '/': (context) => const LoginScreen(),
            '/home': (context) => const MainWrapper(),
            '/settings': (context) => const SettingsScreen(),
            '/insights': (context) => const InsightsScreen(),
            '/task-list': (context) => const TaskListScreen(),
            '/edit-profile': (context) => const EditProfileScreen(),
          },
        );
      },
    );
  }
}
