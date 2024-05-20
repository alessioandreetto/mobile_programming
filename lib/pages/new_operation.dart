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
  TextEditingController _dateController = TextEditingController();

  List<Wallet> _wallets = [];
  String _selectedWallet = '';
  String _selectedWalletForExchangeOut = '';
  String _selectedWalletForExchangeIn = '';
  int _selectedCategoryId = 0;
  int _selectedActionIndex = 0;
  DateTime? _selectedDate;

  List<Category> categories = [
    Category(id: 1, name: 'Auto'),
    Category(id: 2, name: 'Banca'),
    Category(id: 3, name: 'Casa'),
    Category(id: 4, name: 'Intrattenimento'),
    Category(id: 5, name: 'Shopping'),
    Category(id: 6, name: 'Viaggio'),
    Category(id: 7, name: 'Varie'),
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
        _selectedWalletForExchangeOut = _wallets[0].name!;
        _selectedWalletForExchangeIn = _wallets[0].name!;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${_selectedDate!.toLocal()}"
            .split(' ')[0]; // Formatta la data come stringa
      });
    }
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
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Data',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
            if (_selectedActionIndex != 2 && _wallets.isNotEmpty)
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
            if (_selectedActionIndex == 2 && _wallets.length > 1) ...[
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedWalletForExchangeOut,
                onChanged: (newValue) {
                  setState(() {
                    _selectedWalletForExchangeOut = newValue!;
                  });
                },
                items: _wallets.map((wallet) {
                  return DropdownMenuItem(
                    value: wallet.name!,
                    child: Text(wallet.name!),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Portafoglio Uscita',
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedWalletForExchangeIn,
                onChanged: (newValue) {
                  setState(() {
                    _selectedWalletForExchangeIn = newValue!;
                  });
                },
                items: _wallets.map((wallet) {
                  return DropdownMenuItem(
                    value: wallet.name!,
                    child: Text(wallet.name!),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Portafoglio Entrata',
                ),
              ),
            ],
            SizedBox(height: 16.0),
            DropdownButtonFormField<Category>(
              value: categories.firstWhere(
                  (category) => category.id == _selectedCategoryId,
                  orElse: () => categories[0]),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategoryId = newValue!.id;
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
              isSelected: List.generate(
                  actionTypes.length, (index) => _selectedActionIndex == index),
              onPressed: (index) {
                setState(() {
                  _selectedActionIndex = index;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (_selectedActionIndex == 2) {
                  await _performExchangeTransaction(
                      double.parse(_valueController.text));
                } else {
                  await _performRegularTransaction();
                }

                _nameController.clear();
                _valueController.clear();
                _dateController.clear();

                Provider.of<WalletProvider>(context, listen: false)
                    .loadWallets();

                Navigator.pop(context);
              },
              child: Text('Aggiungi Transazione'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performRegularTransaction() async {
    double transactionValue = double.parse(_valueController.text);
    if (_selectedActionIndex == 1) {
      // Uscita selezionata, trasforma il valore in negativo
      transactionValue = -transactionValue;
    }

    // Create a new transaction
    Transaction newTransaction = Transaction(
      name: _nameController.text,
      categoryId: _selectedCategoryId,
      date:
          _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      value: transactionValue,
      transactionId:
          _wallets.firstWhere((wallet) => wallet.name == _selectedWallet).id,
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
  }

  Future<void> _performExchangeTransaction(double value) async {
    // Valore negativo per il portafoglio di uscita
    double outValue = -value;

    // Transazione per il portafoglio di uscita
    Transaction outgoingTransaction = Transaction(
      name: _nameController.text,
      categoryId: _selectedCategoryId,
      date:
          _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      value: outValue,
      transactionId: _wallets
          .firstWhere((wallet) => wallet.name == _selectedWalletForExchangeOut)
          .id,
    );

    // Inserisci la transazione di uscita nel database
    await dbHelper.insertTransaction(outgoingTransaction);
    Wallet existingOutgoingWallet = _wallets
        .firstWhere((wallet) => wallet.name == _selectedWalletForExchangeOut);
    double newOutgoingBalance =
        existingOutgoingWallet.balance! + outgoingTransaction.value!;
    Wallet updatedOutgoingWallet = Wallet(
      id: existingOutgoingWallet.id,
      name: existingOutgoingWallet.name,
      balance: newOutgoingBalance,
    );
    await dbHelper.updateWallet(updatedOutgoingWallet);

    // Transazione per il portafoglio di entrata
    Transaction incomingTransaction = Transaction(
      name: _nameController.text,
      categoryId: _selectedCategoryId,
      date:
          _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      value: value,
      transactionId: _wallets
          .firstWhere((wallet) => wallet.name == _selectedWalletForExchangeIn)
          .id,
    );

    // Inserisci la transazione di entrata nel database
    await dbHelper.insertTransaction(incomingTransaction);
    Wallet existingIncomingWallet = _wallets
        .firstWhere((wallet) => wallet.name == _selectedWalletForExchangeIn);
    double newIncomingBalance =
        existingIncomingWallet.balance! + incomingTransaction.value!;
    Wallet updatedIncomingWallet = Wallet(
      id: existingIncomingWallet.id,
      name: existingIncomingWallet.name,
      balance: newIncomingBalance,
    );
    await dbHelper.updateWallet(updatedIncomingWallet);
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
