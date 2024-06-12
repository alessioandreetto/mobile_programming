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
  int _selectedCategoryId = 0;
  int _selectedActionIndex = 0;
  DateTime? _selectedDate;
  bool _deleteButtonVisible = false;
  bool _isDirty = false;

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

      widget.dateController.text =
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

      if (widget.transaction!.value! < 0) {
        _selectedActionIndex = 1; // Uscita
        widget.valueController.text =
            (widget.transaction!.value! * -1).toString();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          Wallet originalWallet = _wallets.firstWhere(
              (wallet) => wallet.id == widget.transaction!.transactionId);
          _selectedWallet = originalWallet.name!;
        });
      });
    } else {
      _selectedDate = DateTime.now();
      widget.dateController.text =
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _loadWallets() async {
    final wallets = await dbHelper.getWallets();
    setState(() {
      _wallets = wallets;
      if (_wallets.isNotEmpty) {
        final walletProvider =
            Provider.of<WalletProvider>(context, listen: false);
        final selectedWallet =
            walletProvider.wallets[walletProvider.selectedWalletIndex];
        _selectedWallet = widget.transaction != null
            ? _wallets
                .firstWhere(
                    (wallet) => wallet.id == widget.transaction!.transactionId)
                .name!
            : selectedWallet.name!;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime selectedDate = _selectedDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.dateController.text =
            "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
        _isDirty = true;
      });
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Future<bool> _onWillPop() async {
    if (_isDirty) {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Conferma uscita'),
          content: Text(
              'Hai delle modifiche non salvate. Sei sicuro di voler tornare indietro senza salvare?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Sì'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
          ],
        ),
      );
      return confirm == true;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: widget.transaction == null
              ? Text('Nuova Transazione')
              : Text('Modifica Transazione'),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            Visibility(
              visible: _deleteButtonVisible,
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _confirmDeleteTransaction(context);
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: widget.nameController,
                  decoration: InputDecoration(labelText: 'Nome'),
                  onChanged: (_) {
                    setState(() {
                      _isDirty = true;
                    });
                  },
                ),
                TextField(
                  controller: widget.valueController,
                  decoration: InputDecoration(labelText: 'Valore'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (_) {
                    setState(() {
                      _isDirty = true;
                    });
                  },
                ),
                TextField(
                  controller: widget.dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Data',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () {
                    _selectDate(context);
                  },
                ),
                DropdownButtonFormField<Wallet>(
                  value: _wallets.isNotEmpty
                      ? _wallets.firstWhere(
                          (wallet) => wallet.name == _selectedWallet)
                      : null,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedWallet = newValue!.name!;
                      _isDirty = true;
                    });
                    int selectedWalletIndex = _wallets.indexOf(
                        newValue!); // Ottieni l'indice del wallet selezionato
                    Provider.of<WalletProvider>(context, listen: false)
                        .updateSelectedWalletIndex(
                            selectedWalletIndex); // Passa l'indice del wallet
                  },
                  items: _wallets.map((wallet) {
                    return DropdownMenuItem(
                      value: wallet,
                      child: Text(wallet.name!),
                    );
                  }).toList(), // Converte la lista in una lista di DropdownMenuItem

                  decoration: InputDecoration(
                    labelText: 'Portafoglio',
                  ),
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<Category>(
                  value: categories.firstWhere(
                      (category) => category.id == _selectedCategoryId),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategoryId = newValue!.id;
                      _isDirty = true;
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
                  children: actionTypes
                      .map((type) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(type),
                          ))
                      .toList(),
                  isSelected: List.generate(
                    actionTypes.length,
                    (index) => _selectedActionIndex == index,
                  ),
                  onPressed: (index) {
                    setState(() {
                      _selectedActionIndex = index;
                      _isDirty = true;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _saveTransaction,
                  child: Text('Salva'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    final transactionName = widget.nameController.text;
    final transactionValue =
        double.tryParse(widget.valueController.text) ?? 0.0;
    final transactionDate = widget.dateController.text;

    final wallet =
        _wallets.firstWhere((wallet) => wallet.name == _selectedWallet);
    final categoryId = _selectedCategoryId;
    final actionType = _selectedActionIndex == 1 ? 'Uscita' : 'Entrata';

    double finalTransactionValue = transactionValue;
    if (_selectedActionIndex == 1) {
      finalTransactionValue *= -1; // Rendere il valore negativo per l'uscita
    }

    final newTransaction = Transaction(
      name: transactionName,
      value: finalTransactionValue,
      date: transactionDate,
      categoryId: categoryId,
      transactionId: wallet.id,
    );

    if (widget.transaction == null) {
      await dbHelper.insertTransaction(newTransaction);
    } else {
      newTransaction.id = widget.transaction!.id;
      await dbHelper.updateTransaction(newTransaction);
    }

    _showSnackbar(context, 'Transazione salvata con successo');
    _isDirty = false; // Resetta lo stato _isDirty
    Navigator.pop(context, true);
  }

  Future<void> _confirmDeleteTransaction(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conferma cancellazione'),
        content: Text('Sei sicuro di voler cancellare questa transazione?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Sì'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('No'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await dbHelper.deleteTransaction(widget.transaction!.id!);
      _showSnackbar(context, 'Transazione cancellata con successo');
      Navigator.pop(context, true);
    }
  }
}
