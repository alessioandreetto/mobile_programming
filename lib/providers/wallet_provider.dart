import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/database_model.dart'; // Assicurati che il percorso sia corretto

class WalletProvider with ChangeNotifier {
  List<Wallet> _wallets = [];
  String _name = 'User';
  String _valuta = '€';
  int _selectedWalletIndex = 0; // Indice del wallet selezionato
  bool _tipologiaMovimento = true;
  int categorySelected = -1;

  // Getter per i dati
  List<Wallet> get wallets => _wallets;
  String get name => _name;
  String get valuta => _valuta;
  int get selectedWalletIndex => _selectedWalletIndex;
  int get categorySelectedIndex => categorySelected;

  // Metodo per caricare i wallet dal database
  Future<List<Wallet>> loadWallets() async {
    _wallets = await DatabaseHelper().getWallets();
    notifyListeners();
    return _wallets;
  }


  // Metodo per eliminare una transazione e aggiornare il saldo
  void deleteTransaction(int transactionId) async {
    await DatabaseHelper().deleteTransaction(transactionId);
    await reloadWalletBalance(); // Aggiorna il saldo del wallet dopo l'eliminazione della transazione
  }

  // Metodo per aggiornare una transazione e aggiornare il saldo
  void updateTransaction(Transaction transaction) async {
    await DatabaseHelper().updateTransaction(transaction);
    await reloadWalletBalance(); // Aggiorna il saldo del wallet dopo l'aggiornamento della transazione
  }

  // Metodo per inserire una nuova transazione e aggiornare il saldo
  void insertTransaction(Transaction transaction) async {
    await DatabaseHelper().insertTransaction(transaction);
    await reloadWalletBalance(); // Aggiorna il saldo del wallet dopo l'inserimento della transazione
  }

  // Metodo per ricaricare i bilanci dei wallet
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

  // Metodo per aggiornare il nome dell'account
  Future<void> updateAccountName(String newName) async {
    _name = newName;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('account_name', newName);
  }

  // Metodo per caricare il nome dell'account dalle preferenze condivise
  Future<void> loadAccountName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('account_name') ?? 'User';
    notifyListeners();
  }

  // Metodo per aggiornare la valuta
  Future<void> updateValuta(String newValuta) async {
    _valuta = newValuta;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('valuta', newValuta);
  }

  // Metodo per caricare la valuta dalle preferenze condivise
  Future<void> loadValuta() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _valuta = prefs.getString('valuta') ?? '€';
    notifyListeners();
  }


int getWalletCount() {
  return _wallets.length;
}

  // Metodo per ricaricare i wallet
  Future<void> refreshWallets() async {
    _wallets = await loadWallets();
    notifyListeners();
  }

  // Metodo per verificare se ci sono transazioni per un determinato wallet
  Future<bool> hasTransactionsForWallet(int walletId) async {
    List<Transaction> transactions =
        await DatabaseHelper().getTransactionsForWallet(walletId);
    return transactions.isNotEmpty;
  }

  // Metodo per aggiornare l'indice del wallet selezionato
  void updateSelectedWalletIndex(int index) {
    _selectedWalletIndex = index;
    print (_selectedWalletIndex);
    notifyListeners();
  }

  // Getter per l'indice del wallet selezionato
  int getSelectedWalletIndex() {
    print (_selectedWalletIndex);
    return _selectedWalletIndex;
  }

  void updateSelectedCategoryIndex(int index) {
    categorySelected = index;
   
    notifyListeners();
  }

  // Getter per l'indice del wallet selezionato
  int getSelectedCategoryIndex() {
    return categorySelected;
  }


    void updateTipologia(bool value) {
    _tipologiaMovimento= value;
    print (_tipologiaMovimento);
    notifyListeners();
  }

    bool getTipologiaMovimento() {
    return _tipologiaMovimento;
  }
}
