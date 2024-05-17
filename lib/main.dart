import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'page-selector.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'providers/wallet_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()..loadWallets()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BottomBarDemo(),
      ),
    );
  }
}
