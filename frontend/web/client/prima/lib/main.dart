import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/pages/home/home_page.dart';
import 'package:prima/pages/profile/profile_page.dart';
import 'package:prima/pages/offers/offers_page.dart';
import 'package:prima/pages/chat/chat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZS Laundry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SourceSansPro',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/offers': (context) => const OffersPage(),
        '/chat': (context) => const ChatPage(),
      },
    );
  }
}
