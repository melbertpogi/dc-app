import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:minmalecommerce/firebase_options.dart';
import 'package:minmalecommerce/models/shop_model.dart';
import 'package:minmalecommerce/pages/TransactionHistory_user.dart';
import 'package:minmalecommerce/pages/about_page.dart';
import 'package:minmalecommerce/pages/auth_page.dart';
import 'package:minmalecommerce/pages/cart_page.dart';
import 'package:minmalecommerce/pages/intro_page.dart';
import 'package:minmalecommerce/pages/settings_page.dart';
import 'package:minmalecommerce/pages/shop_page.dart';
import 'package:minmalecommerce/themes/theme_provider.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => Shop(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthPage(),
      routes: {
        IntroPage.id: (context) => const IntroPage(),
        ShopPage.id: (context) => ShopPage(),
        CartPage.id: (context) => const CartPage(),
        SettingsPage.id: (context) => const SettingsPage(),
        AboutPage.id: (context) => const AboutPage(),
        TransactionListPage.id: (context) => TransactionListPage(),
      },
    );
  }
}
