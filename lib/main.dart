import 'package:flutter/material.dart';
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
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(), // Indicatore di caricamento
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
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
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: isFirstTimeUser ? PageIndicatorDemo() : BottomBarDemo(),
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
