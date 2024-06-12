import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'providers/wallet_provider.dart';
import 'page-selector.dart';
import 'pages/initialPage/demo.dart';
import 'pages/setting.dart'; // Assicurati che il percorso sia corretto

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkFirstTimeUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }
        final isFirstTimeUser = snapshot.data ?? true;
        return AdaptiveTheme(
          light: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
          ),
          dark: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
          ),
          initial: AdaptiveThemeMode.system,
          builder: (theme, darkTheme) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                  create: (_) => WalletProvider()..loadWallets()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme,
              darkTheme: darkTheme,
              home: isFirstTimeUser ? PageIndicatorDemo() : BottomBarDemo(),
            ),
          ),
        );
      },
    );
  }

  Future<bool> checkFirstTimeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('firstTimeUser') ?? true;
  }
}
