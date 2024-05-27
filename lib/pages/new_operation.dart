import 'package:flutter/material.dart';
import '../model/database_model.dart';
import '../providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});
}

class NewTransactionPage extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController valueController;
  final TextEditingController dateController;
  final Transaction? transaction;

  NewTransactionPage({this.transaction})
      : nameController = TextEditingController(text: transaction?.name),
        valueController = TextEditingController(
          text: transaction != null && transaction.value! < 0
              ? (transaction.value! * -1).toString()
              : transaction?.value.toString(),
        ),
        dateController = TextEditingController(text: transaction?.date ?? '');

  @override
  _NewTransactionPageState createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  final dbHelper = DatabaseHelper();
  List<Wallet> _wallets = [];
  String _selectedWallet = '';
  String _selectedWalletForExchangeOut = '';
  String _selectedWalletForExchangeIn = '';
  int _selectedCategoryId = 0;
  int _selectedActionIndex = 0;
  DateTime? _selectedDate;
  bool _deleteButtonVisible = false;

  List<Category> categories = [
    Category(id: 0, name: 'Auto'),
    Category(id: 1, name: 'Banca'),
    Category(id: 2, name: 'Casa'),
    Category(id: 3, name: 'Intrattenimento'),
    Category(id: 4, name: 'Shopping'),
    Category(id: 5, name: 'Viaggio'),
    Category(id: 6, name: 'Varie'),
  ];
  List<String> actionTypes = ['Entrata', 'Uscita', 'Exchange'];

  @override
  void initState() {
    super.initState();
    _loadWallets();
    _deleteButtonVisible = widget.transaction != null;

    if (widget.transaction != null) {
      _selectedCategoryId = widget.transaction!.categoryId!;
      _selectedDate = DateTime.parse(widget.transaction!.date!);

      if (widget.transaction!.value! < 0) {
        _selectedActionIndex = 1; // Uscita
        widget.valueController.text =
            (widget.transaction!.value! * -1).toString();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedWallet = _wallets
              .firstWhere(
                  (wallet) => wallet.id == widget.transaction!.transactionId)
              .name!;
          _selectedWalletForExchangeOut = _selectedWallet;
          _selectedWalletForExchangeIn = _selectedWallet;
        });
      });
    }
  }

  Future<void> _loadWallets() async {
    final wallets = await dbHelper.getWallets();
    setState(() {
      _wallets = wallets;
      if (_wallets.isNotEmpty) {
        _selectedWallet = widget.transaction != null
            ? _wallets
                .firstWhere(
                    (wallet) => wallet.id == widget.transaction!.transactionId)
                .name!
            : _wallets[0].name!;
        _selectedWalletForExchangeOut = _selectedWallet;
        _selectedWalletForExchangeIn = _selectedWallet;
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
        widget.dateController.text =
            "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: widget.transaction == null
            ? Text('Nuova Transazione')
            : Text('Modifica Transazione'),
        elevation: 0,
        actions: [
          Visibility(
            visible: _deleteButtonVisible,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteTransaction(context);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: widget.nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: widget.valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Valore'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            TextField(
              controller: widget.dateController,
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
                if (_validateFields()) {
                  if (_selectedActionIndex == 2) {
                    await _performExchangeTransaction(
                        double.parse(widget.valueController.text));
                  } else {
                    await _performRegularTransaction();
                  }

                  Provider.of<WalletProvider>(context, listen: false)
                      .loadWallets();

                  _showSnackbar(
                      context,
                      widget.transaction == null
                          ? 'Transazione aggiunta con successo!'
                          : 'Transazione modificata con successo!');
                  _navigateToHome(context);
                } else {
                  _showSnackbar(context, 'Inserisci tutti i campi');
                }
              },
              child: Text(widget.transaction == null
                  ? 'Aggiungi Transazione'
                  : 'Modifica Transazione'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateFields() {
    return widget.nameController.text.isNotEmpty &&
        widget.valueController.text.isNotEmpty &&
        widget.dateController.text.isNotEmpty;
  }

  Future<void> _performRegularTransaction() async {
    double transactionValue = double.parse(widget.valueController.text);
    if (_selectedActionIndex == 1) {
      transactionValue = -transactionValue;
    }

    if (widget.transaction != null) {
      Transaction updatedTransaction = Transaction(
        id: widget.transaction!.id,
        name: widget.nameController.text,
        categoryId: _selectedCategoryId,
        date: _selectedDate?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        value: transactionValue,
        transactionId:
            _wallets.firstWhere((wallet) => wallet.name == _selectedWallet).id,
      );

      await dbHelper.updateTransaction(updatedTransaction);

      Wallet existingWallet =
          _wallets.firstWhere((wallet) => wallet.name == _selectedWallet);
      double newBalance = existingWallet.balance! +
          (updatedTransaction.value! - widget.transaction!.value!);
      Wallet updatedWallet = Wallet(
        id: existingWallet.id,
        name: existingWallet.name,
        balance: newBalance,
      );
      await dbHelper.updateWallet(updatedWallet);
    } else {
      Transaction newTransaction = Transaction(
        name: widget.nameController.text,
        categoryId: _selectedCategoryId,
        date: _selectedDate?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        value: transactionValue,
        transactionId:
            _wallets.firstWhere((wallet) => wallet.name == _selectedWallet).id,
      );

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
  }

  Future<void> _performExchangeTransaction(double value) async {
    double outValue = -value;

    Transaction outgoingTransaction = Transaction(
      name: widget.nameController.text,
      categoryId: _selectedCategoryId,
      date:
          _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      value: outValue,
      transactionId: _wallets
          .firstWhere((wallet) => wallet.name == _selectedWalletForExchangeOut)
          .id,
    );

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

    Transaction incomingTransaction = Transaction(
      name: widget.nameController.text,
      categoryId: _selectedCategoryId,
      date:
          _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      value: value,
      transactionId: _wallets
          .firstWhere((wallet) => wallet.name == _selectedWalletForExchangeIn)
          .id,
    );

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
      actionTypes = ['Entrata', 'Uscita'];
      buttons = actionTypes.map((action) {
        return Text(action);
      }).toList();
    } else {
      buttons = actionTypes.map((action) {
        return Text(action);
      }).toList();
    }
    return buttons;
  }

  void _deleteTransaction(BuildContext context) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Elimina transazione'),
        content: Text('Sei sicuro di voler eliminare questa transazione?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed) {
      if (widget.transaction != null) {
        // Ottieni il valore della transazione eliminata
        double deletedTransactionValue = widget.transaction!.value!;

        // Elimina la transazione
        Provider.of<WalletProvider>(context, listen: false)
            .deleteTransaction(widget.transaction!.id!);
        Navigator.of(context).pop();

        // Aggiorna il saldo del wallet
        Wallet wallet = _wallets.firstWhere(
          (wallet) => wallet.name == _selectedWallet,
          orElse: () => Wallet(
              id: -1,
              name: '',
              balance: 0), // Wallet fittizio nel caso non trovi il wallet
        );

        if (wallet.id != -1) {
          // Se il wallet è stato trovato, aggiorna il saldo
          double newBalance = wallet.balance! - deletedTransactionValue;
          Wallet updatedWallet = Wallet(
            id: wallet.id,
            name: wallet.name,
            balance: newBalance,
          );
          await dbHelper.updateWallet(updatedWallet);
        }
      }
    }
  }
}
