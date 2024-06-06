import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/database_model.dart'; // Assicurati che il percorso sia corretto

class WalletProvider with ChangeNotifier {
  List<Wallet> _wallets = [];
  String _name = 'User';
  String _valuta = '€';
  int _selectedWalletIndex =
      0; // Aggiunta della variabile per l'indice del wallet selezionato

  List<Wallet> get wallets => _wallets;

  String get name => _name;
  String get valuta => _valuta;
  int get selectedWalletIndex =>
      _selectedWalletIndex; // Getter per l'indice del wallet selezionato

  Future<List<Wallet>> loadWallets() async {
    _wallets = await DatabaseHelper().getWallets();
    notifyListeners();
    return _wallets;
  }

  void deleteTransaction(int transactionId) async {
    await DatabaseHelper().deleteTransaction(transactionId);
    await reloadWalletBalance(); // Aggiorna il saldo del wallet dopo l'eliminazione della transazione
  }

  void updateTransaction(Transaction transaction) async {
    await DatabaseHelper().updateTransaction(transaction);
    await reloadWalletBalance(); // Aggiorna il saldo del wallet dopo l'aggiornamento della transazione
  }

  void insertTransaction(Transaction transaction) async {
    await DatabaseHelper().insertTransaction(transaction);
    await reloadWalletBalance(); // Aggiorna il saldo del wallet dopo l'inserimento della transazione
  }

  void addWallet(String name, double initialBalance) {
    final newWallet = Wallet(name: name, balance: initialBalance);
    _wallets.add(newWallet);
    notifyListeners();
    DatabaseHelper().insertWallet(newWallet);
  }

  Future<void> reloadWalletBalance() async {
    _wallets = await loadWallets();
    for (Wallet wallet in _wallets) {
      List<Transaction> transactions =
          await DatabaseHelper().getTransactionsForWallet(wallet.id!);
      double updatedBalance = transactions.fold(
          0, (prev, transaction) => prev + transaction.value!);
      wallet.balance = updatedBalance;
    }
    notifyListeners();
  }

  // Aggiungi un metodo per aggiornare il nome dell'account
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
  }

  Future<void> loadValuta() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _valuta = prefs.getString('valuta') ?? '€';
    notifyListeners();
  }

  Future<void> refreshWallets() async {
    _wallets = await loadWallets(); // Ricarica i portafogli
    notifyListeners();
  }

  void updateSelectedWalletIndex(int index) {
    _selectedWalletIndex = index;
    notifyListeners();
  }
}
