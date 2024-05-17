import 'package:flutter/material.dart';
import '../model/database_model.dart';
import '../providers/wallet_provider.dart';
import 'package:provider/provider.dart';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});
}

class NewTransactionPage extends StatefulWidget {
  @override
  _NewTransactionPageState createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  final dbHelper = DatabaseHelper();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _valueController = TextEditingController();

  List<Wallet> _wallets = [];
  String _selectedWallet = '';
  int _selectedCategoryId = 0;
  int _selectedActionIndex = 0; // Aggiunto per tenere traccia dell'azione selezionata

  List<Category> categories = [
    Category(id: 1, name: 'Category 1'),
    Category(id: 2, name: 'Category 2'),
    Category(id: 3, name: 'Category 3'),
  ];
  List<String> actionTypes = ['Entrata', 'Uscita', 'Exchange'];

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final wallets = await dbHelper.getWallets();
    setState(() {
      _wallets = wallets;
      if (_wallets.isNotEmpty) {
        _selectedWallet = _wallets[0].name!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuova Transazione'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Valore'),
            ),
            if (_wallets.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedWallet,
                onChanged: (newValue) {
                  setState(() {
                    _selectedWallet = newValue!;
                  });
                },
                items: _wallets.map((wallet) {
                  return DropdownMenuItem(
                    value: wallet.name!,
                    child: Text(wallet.name!),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Portafoglio',
                ),
              ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<Category>(
              value: categories.firstWhere((category) => category.id == _selectedCategoryId, orElse: () => categories[0]), // Updated
              onChanged: (newValue) {
                setState(() {
                  _selectedCategoryId = newValue!.id; // Updated
                });
              },
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Categoria',
              ),
            ),
            SizedBox(height: 16.0),
            ToggleButtons(
              children: _buildToggleButtons(),
              isSelected: List.generate(actionTypes.length, (index) => _selectedActionIndex == index),
              onPressed: (index) {
                setState(() {
                  _selectedActionIndex = index;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Ottieni il segno corretto della transazione in base all'azione selezionata
                double transactionValue = double.parse(_valueController.text);
                if (_selectedActionIndex == 1) {
                  // Uscita selezionata, trasforma il valore in negativo
                  transactionValue = -transactionValue;
                }

                // Create a new transaction
                Transaction newTransaction = Transaction(
                  name: _nameController.text,
                  categoryId: _selectedCategoryId,
                  date: DateTime.now().toString(),
                  value: transactionValue,
                  transactionId: _wallets
                      .firstWhere((wallet) => wallet.name == _selectedWallet)
                      .id,
                );

                // Insert the transaction into the database
                await dbHelper.insertTransaction(newTransaction);
                Wallet existingWallet =
                    _wallets.firstWhere((wallet) => wallet.name == _selectedWallet);

                double newBalance = existingWallet.balance! + newTransaction.value!;

                Wallet updatedWallet = Wallet(
                  id: existingWallet.id,
                  name: existingWallet.name,
                  balance: newBalance,
                );
                await dbHelper.updateWallet(updatedWallet);

                _nameController.clear();
                _valueController.clear();

                Provider.of<WalletProvider>(context, listen: false).loadWallets();

                Navigator.pop(context);
              },
              child: Text('Aggiungi Transazione'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildToggleButtons() {
    List<Widget> buttons = [];
    if (_wallets.length == 1) {
      // Se ho un solo portafoglio, mostrare solo Entrata e Uscita
      
      actionTypes = ['Entrata', 'Uscita'];
      buttons = actionTypes.map((action) {
        return Text(action);
      }).toList();
    } else {
      // Altrimenti, mostrare tutte e tre le opzioni

      buttons = actionTypes.map((action) {
        return Text(action);
      }).toList();
    }
    return buttons;
  }
}
