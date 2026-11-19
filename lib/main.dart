import 'package:flutter/material.dart';

import 'views/home_page.dart';

void main() {
  runApp(const TechNewsApp());
}

class TechNewsApp extends StatelessWidget {
  const TechNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechNews Indonesia',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14213D)),
      ),
      home: const HomePage(),
    );
  }
}
