import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/services/preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/folders_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/tasks_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI navigation bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final prefsService = await PreferencesService.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(prefsService),
        ),
        ChangeNotifierProvider(
          create: (_) => FoldersProvider()..loadFolders(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotesProvider()..loadNotes(),
        ),
        ChangeNotifierProvider(
          create: (_) => TasksProvider()..loadTasks(),
        ),
      ],
      child: const VerveJotApp(),
    ),
  );
}

class VerveJotApp extends StatelessWidget {
  const VerveJotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.oledDarkTheme,
      home: const DashboardScreen(),
    );
  }
}
