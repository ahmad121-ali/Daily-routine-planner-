import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screen/login_screen/login.dart';
import 'screen/main_wrapper.dart';
import 'screen/settings_screen/settings.dart';
import 'screen/insights_screen/insights.dart';
import 'screen/task_list_screen/task_list.dart';
import 'screen/edit_profile_screen/edit_profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const MainWrapper(), // Points to MainWrapper now
        '/settings': (context) => const SettingsScreen(),
        '/insights': (context) => const InsightsScreen(),
        '/task-list': (context) => const TaskListScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}
