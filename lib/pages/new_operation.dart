import 'package:flutter/material.dart';
import '../model/database_model.dart';

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
  int _selectedCategoryId = 0; // Updated
  String _selectedActionType = '';

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
            ElevatedButton(
              onPressed: () async {
                // Create a new transaction
                Transaction newTransaction = Transaction(
                  name: _nameController.text,
                  categoryId: _selectedCategoryId, // Updated
                  date: DateTime.now().toString(),
                  value: double.parse(_valueController.text),
                  transactionId: _wallets
                      .firstWhere((wallet) => wallet.name == _selectedWallet)
                      .id, // Using the id of the selected wallet
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

                // Clear text fields after insertion
                _nameController.clear();
                _valueController.clear();

                // Show a success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transazione aggiunta con successo'),
                  ),
                );
              },
              child: Text('Aggiungi Transazione'),
            ),
          ],
        ),
      ),
    );
  }
}
