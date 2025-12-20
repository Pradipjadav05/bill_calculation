import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'ui/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Electricity Bill Split',
      theme: AppTheme.lightTheme(),
      home: const HomeScreen(),
    );
  }
}
