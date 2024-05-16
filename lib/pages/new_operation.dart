import 'package:flutter/material.dart';
import '../model/database_model.dart';

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
  String _selectedCategory = '';
  String _selectedActionType = '';

  List<String> categories = ['Category 1', 'Category 2', 'Category 3'];
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
/*             DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Categoria',
              ),
            ), */
/*             DropdownButtonFormField<String>(
              value: _selectedActionType,
              onChanged: (newValue) {
                setState(() {
                  _selectedActionType = newValue!;
                });
              },
              items: actionTypes.map((actionType) {
                return DropdownMenuItem(
                  value: actionType,
                  child: Text(actionType),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Tipologia di Azione',
              ),
            ), */
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Create a new transaction
                Transaction newTransaction = Transaction(
                  name: _nameController.text,
                  categoryId: categories.indexOf(_selectedCategory),
                  date: DateTime.now().toString(),
                  value: double.parse(_valueController.text),
                  transactionId: _wallets
                      .firstWhere((wallet) => wallet.name == _selectedWallet)
                      .id, // Using the id of the selected wallet
                );

                // Insert the transaction into the database
                await dbHelper.insertTransaction(newTransaction);

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
