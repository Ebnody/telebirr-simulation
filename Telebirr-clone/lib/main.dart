import 'package:flutter/material.dart';
import 'package:telebirr/colors.dart';
import 'package:telebirr/screens/activation_screen.dart';
import 'package:telebirr/screens/main_screen.dart';
import 'package:telebirr/utils/subscription_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'telebirr',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: mainColor,
          primary: mainColor,
        ),
        useMaterial3: true,
      ),
      home: const _AppEntry(),
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SubscriptionManager.isActive(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }
        final active = snapshot.data ?? false;
        return active ? const MainScreen() : const ActivationScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/app_logo.png', width: 120, height: 120),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color.fromRGBO(140, 199, 63, 1),
            ),
          ],
        ),
      ),
    );
  }
}
