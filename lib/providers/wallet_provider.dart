import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/database_model.dart';

class WalletProvider with ChangeNotifier {
  List<Wallet> _wallets = [];
  String _name = 'User';
  String _valuta = '€';
  int _selectedWalletIndex = 0;
  bool _tipologiaMovimento = true;
  int categorySelected = -1;

  // Getter per i dati
  List<Wallet> get wallets => _wallets;
  String get name => _name;
  String get valuta => _valuta;
  int get selectedWalletIndex => _selectedWalletIndex;
  int get categorySelectedIndex => categorySelected;

  Future<List<Wallet>> loadWallets() async {
    _wallets = await DatabaseHelper().getWallets();
    notifyListeners();
    return _wallets;
  }

  void deleteTransaction(int transactionId) async {
    await DatabaseHelper().deleteTransaction(transactionId);
    await reloadWalletBalance();
  }

  void updateTransaction(Transaction transaction) async {
    await DatabaseHelper().updateTransaction(transaction);
    await reloadWalletBalance();
  }

  void insertTransaction(Transaction transaction) async {
    await DatabaseHelper().insertTransaction(transaction);
    await reloadWalletBalance();
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

  int getWalletCount() {
    return _wallets.length;
  }

  Future<void> refreshWallets() async {
    _wallets = await loadWallets();
    notifyListeners();
  }

  Future<bool> hasTransactionsForWallet(int walletId) async {
    List<Transaction> transactions =
        await DatabaseHelper().getTransactionsForWallet(walletId);
    return transactions.isNotEmpty;
  }

  void updateSelectedWalletIndex(int index) {
    _selectedWalletIndex = index;
    //print(_selectedWalletIndex);
    notifyListeners();
  }

  int getSelectedWalletIndex() {
    //print(_selectedWalletIndex);
    return _selectedWalletIndex;
  }

  void updateSelectedCategoryIndex(int index) {
    categorySelected = index;

    notifyListeners();
  }

  int getSelectedCategoryIndex() {
    return categorySelected;
  }

  void updateTipologia(bool value) {
    _tipologiaMovimento = value;
    print(_tipologiaMovimento);
    notifyListeners();
  }

  bool getTipologiaMovimento() {
    return _tipologiaMovimento;
  }
}
