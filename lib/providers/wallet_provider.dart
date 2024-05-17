import 'package:flutter/foundation.dart';
import '../model/database_model.dart';  // Assicurati che il percorso sia corretto

class WalletProvider with ChangeNotifier {
  List<Wallet> _wallets = [];

  List<Wallet> get wallets => _wallets;

  Future<List<Wallet>> loadWallets() async {
    _wallets = await DatabaseHelper().getWallets();
    notifyListeners();
    return _wallets; // Aggiungi questa riga per restituire la lista di wallet
  }
}
