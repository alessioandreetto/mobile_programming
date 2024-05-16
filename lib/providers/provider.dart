import 'package:flutter/material.dart';

// Modello dei dati per il portafoglio
class Wallet {
  final int id;
  final String name;
  final double balance;

  Wallet({required this.id, required this.name, required this.balance});
}

// Provider per gestire i dati dei portafogli
class WalletProvider extends ChangeNotifier {
  List<Wallet> _wallets = []; // Lista dei portafogli

  // Metodo per ottenere i portafogli
  List<Wallet> get wallets => _wallets;

  // Metodo per aggiornare i portafogli e notificare i widget ascoltatori
  void updateWallets(List<Wallet> wallets) {
    _wallets = wallets;
    notifyListeners();
  }
}
