import 'package:flutter/foundation.dart';
import '../model/database_model.dart'; // Assicurati che il percorso sia corretto
import 'package:shared_preferences/shared_preferences.dart';

class WalletProvider with ChangeNotifier {
  List<Wallet> _wallets = [];
  String _name = 'User';
  String _valuta = '€';

  List<Wallet> get wallets => _wallets;

  String get name => _name;
  String get valuta => _valuta;
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

  void insertTransaction(Transaction transaction) async {
    await DatabaseHelper().insertTransaction(transaction);
    // Ricarica i portafogli dopo l'inserimento della transazione
    await loadWallets();
  }

  Future<void> updateAccountName(String newName) async {
    _name = newName;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('account_name', newName);
  }

  Future<void> loadAccountName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('account_name') ?? 'User';
    notifyListeners();
  }

  Future<void> updateValuta(String newValuta) async {
    _valuta = newValuta;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('valuta', newValuta);
    print('valuta' + _valuta);
  }

  Future<void> loadValuta() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _valuta = prefs.getString('valuta') ?? '€';
    print('Valuta caricata: $_valuta');
    notifyListeners();
  }
}
