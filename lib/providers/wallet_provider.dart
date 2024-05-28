import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/database_model.dart'; // Assicurati che il percorso sia corretto

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
    return _wallets;
  }

  void deleteTransaction(int transactionId) async {
    await DatabaseHelper().deleteTransaction(transactionId);
    reloadWalletBalance(); // Aggiorna il saldo del wallet dopo l'eliminazione della transazione
  }

  void updateTransaction(Transaction transaction) async {
    await DatabaseHelper().updateTransaction(transaction);
    reloadWalletBalance(); // Aggiorna il saldo del wallet dopo l'aggiornamento della transazione
  }

  void insertTransaction(Transaction transaction) async {
    await DatabaseHelper().insertTransaction(transaction);
    reloadWalletBalance(); // Aggiorna il saldo del wallet dopo l'inserimento della transazione
  }

  Future<void> reloadWalletBalance() async {
    List<Wallet> wallets = await loadWallets();
    for (Wallet wallet in wallets) {
      List<Transaction> transactions =
          await DatabaseHelper().getTransactionsForWallet(wallet.id!);
      double updatedBalance = transactions.fold(
          0, (prev, transaction) => prev + transaction.value!);
      wallet.balance = updatedBalance;
    }
    notifyListeners();
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
