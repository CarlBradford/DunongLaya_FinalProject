import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'providers/app_state_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/article_provider.dart';
import 'providers/user_provider.dart'; 
import 'screens/app_navigator.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const TheAxisApp(),
    ),
  );
}

class TheAxisApp extends StatelessWidget {
  const TheAxisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The AXIS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppNavigator(),
    );
  }
}


