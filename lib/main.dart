import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/wallet_provider.dart';
import 'page-selector.dart';
import 'pages/initialPage/demo.dart';

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
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blue,
            ),
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(), // Indicatore di caricamento
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blue,
            ),
            home: Scaffold(
              body: Center(
                child: Text(
                    'Error: ${snapshot.error}'), // Mostra un messaggio di errore se si verifica un errore durante il controllo
              ),
            ),
          );
        }
        final isFirstTimeUser = snapshot.data ?? true;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) => WalletProvider()..loadWallets()),
          ],
          child: AdaptiveTheme(
            light: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blue,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              cardColor: Colors.white,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
              ),
            ),
            dark: ThemeData(
              brightness: Brightness.dark,
              colorSchemeSeed: Colors.blue,
              scaffoldBackgroundColor: Colors.black,
              cardColor: Colors.grey[900],
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
              ),
            ),
            initial: AdaptiveThemeMode.light,
            builder: (theme, darkTheme) => MaterialApp(
              theme: theme,
              darkTheme: darkTheme,
              debugShowCheckedModeBanner: false,
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
