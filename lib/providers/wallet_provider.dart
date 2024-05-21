import 'package:flutter/foundation.dart';
import '../model/database_model.dart'; // Assicurati che il percorso sia corretto

class WalletProvider with ChangeNotifier {
  List<Wallet> _wallets = [];

  List<Wallet> get wallets => _wallets;

  Future<List<Wallet>> loadWallets() async {
    _wallets = await DatabaseHelper().getWallets();
    notifyListeners();
    return _wallets; // Aggiungi questa riga per restituire la lista di wallet
  }

  void deleteTransaction(int transactionId) async {
    await DatabaseHelper().deleteTransaction(transactionId);
    // Ricarica i portafogli dopo l'eliminazione della transazione
    await loadWallets();
  }

  void updateTransaction(Transaction transaction) async {
    await DatabaseHelper().updateTransaction(transaction);
    // Ricarica i portafogli dopo l'aggiornamento della transazione
    await loadWallets();
  }
}
