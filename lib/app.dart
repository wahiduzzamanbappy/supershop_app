import 'package:flutter/material.dart';
import 'package:supershop_app/ui/widgets/main_nav_bar.dart';

class SuperShopApp extends StatelessWidget {
  const SuperShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SuperShop Management',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4CAF50),
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(), isDense: true),
      ),
      home: const MainNavBar(),
    );
  }
}