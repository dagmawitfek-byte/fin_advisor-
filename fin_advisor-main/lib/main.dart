import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/hive_service.dart';
import 'services/sms_listener.dart';
import 'theme/app_theme.dart';
import 'screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: FinAdvisorApp()));
}

class FinAdvisorApp extends StatefulWidget {
  const FinAdvisorApp({super.key});

  @override
  State<FinAdvisorApp> createState() => _FinAdvisorAppState();
}

class _FinAdvisorAppState extends State<FinAdvisorApp> {
  @override
  void initState() {
    super.initState();
    // Initialize SMS listener after app is fully loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SmsListener().initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinAdvisor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeShell(),
    );
  }
}
