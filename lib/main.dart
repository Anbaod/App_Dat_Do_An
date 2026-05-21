import 'package:flutter/material.dart';
import 'package:food_delivery/common/cart_provider.dart';
import 'package:food_delivery/common/locator.dart';
import 'package:food_delivery/view/login/welcome_view.dart';
import 'package:food_delivery/view/on_boarding/startup_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpLocator();

  prefs = await SharedPreferences.getInstance();

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery',
      debugShowCheckedModeBanner: false,
      navigatorKey: locator<NavigationService>().navigatorKey,
      theme: ThemeData(
        fontFamily: "Metropolis",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const StartupView(),
      routes: {
        'welcome': (context) => const WelcomeView(),
      },
    );
  }
}
