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

  String? _initialName;
  String? _initialValue;
  String? _initialDate;
  String? _initialWallet;
  int? _initialCategoryId;
  int? _initialActionIndex;

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
      _selectedActionIndex = widget.transaction!.value! < 0 ? 1 : 0;

      _initialName = widget.transaction!.name;
      _initialValue = (widget.transaction!.value! < 0
              ? (widget.transaction!.value! * -1)
              : widget.transaction!.value)
          .toString();
      _initialDate = widget.transaction!.date;
      _initialCategoryId = widget.transaction!.categoryId;
      _initialActionIndex = _selectedActionIndex;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          Wallet originalWallet = _wallets.firstWhere(
              (wallet) => wallet.id == widget.transaction!.transactionId);
          _selectedWallet = originalWallet.name!;
          _initialWallet = _selectedWallet;
        });
      });
    } else {
      _selectedDate = DateTime.now();
      widget.dateController.text =
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      _initialName = '';
      _initialValue = '';
      _initialDate = widget.dateController.text;
      _initialCategoryId = 0;
      _initialActionIndex = 0;
    }
  }

  bool isDirty() {
    return widget.nameController.text != _initialName ||
        widget.valueController.text != _initialValue ||
        widget.dateController.text != _initialDate ||
        _selectedWallet != _initialWallet ||
        _selectedCategoryId != _initialCategoryId ||
        _selectedActionIndex != _initialActionIndex;
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
        if (_initialWallet == null) {
          _initialWallet = _selectedWallet;
        }
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

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDirty()) {
          bool? discardChanges = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Conferma uscita'),
              content: Text(
                  'Hai delle modifiche non salvate. Sei sicuro di voler tornare indietro senza salvare?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Si'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                ),
              ],
            ),
          );
          return discardChanges ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: widget.transaction == null
              ? Text('Nuova Transazione')
              : Text('Modifica Transazione'),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (isDirty()) {
                showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Modifiche non salvate'),
                    content: Text(
                        'Hai delle modifiche non salvate. Vuoi davvero uscire?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Si'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('No'),
                      ),
                    ],
                  ),
                ).then((discardChanges) {
                  if (discardChanges ?? false) {
                    Navigator.of(context).pop();
                  }
                });
              } else {
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
                ),
                TextField(
                  controller: widget.valueController,
                  decoration: InputDecoration(labelText: 'Valore'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
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
                      _wallets.length >= 2
                          ? actionTypes.length
                          : actionTypes.length - 1,
                      (index) => _selectedActionIndex == index),
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
                      await _performRegularTransaction();

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
        ),
      ),
    );
  }

  bool _validateFields() {
    return widget.nameController.text.isNotEmpty &&
        widget.valueController.text.isNotEmpty &&
        widget.dateController.text.isNotEmpty;
  }

  List<Widget> _buildToggleButtons() {
    List<Widget> buttons = actionTypes.map((type) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(type),
      );
    }).toList();
    if (_wallets.length < 2) {
      buttons.removeLast();
    }
    return buttons;
  }

  Future<void> _performRegularTransaction() async {
    double transactionValue = double.parse(widget.valueController.text);
    if (_selectedActionIndex == 1) {
      transactionValue = -transactionValue;
    }

    Wallet selectedWallet =
        _wallets.firstWhere((wallet) => wallet.name == _selectedWallet);

    if (widget.transaction != null) {
      Wallet originalWallet = _wallets.firstWhere(
          (wallet) => wallet.id == widget.transaction!.transactionId);

      originalWallet.balance =
          originalWallet.balance! - widget.transaction!.value!;
      await dbHelper.updateWallet(originalWallet);

      selectedWallet.balance = selectedWallet.balance! + transactionValue;
      await dbHelper.updateWallet(selectedWallet);

      widget.transaction!.transactionId = selectedWallet.id;
      widget.transaction!.name = widget.nameController.text;
      widget.transaction!.categoryId = _selectedCategoryId;
      widget.transaction!.date =
          _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String();
      widget.transaction!.value = transactionValue;
      await dbHelper.updateTransaction(widget.transaction!);
    } else {
      Transaction newTransaction = Transaction(
        name: widget.nameController.text,
        categoryId: _selectedCategoryId,
        date: _selectedDate?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        value: transactionValue,
        transactionId: selectedWallet.id,
      );

      await dbHelper.insertTransaction(newTransaction);

      double newBalance = selectedWallet.balance! + transactionValue;
      Wallet updatedWallet = Wallet(
        id: selectedWallet.id,
        name: selectedWallet.name,
        balance: newBalance,
      );
      await dbHelper.updateWallet(updatedWallet);
    }
  }

  Future<void> _confirmDeleteTransaction(BuildContext context) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conferma Eliminazione'),
        content: Text('Sei sicuro di voler eliminare questa transazione?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Si'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _deleteTransaction(context);
    }
  }

  Future<void> _deleteTransaction(BuildContext context) async {
    if (widget.transaction != null) {
      Wallet wallet = _wallets.firstWhere(
          (wallet) => wallet.id == widget.transaction!.transactionId);

      wallet.balance = wallet.balance! - widget.transaction!.value!;

      await dbHelper.updateWallet(wallet);
      await dbHelper.deleteTransaction(widget.transaction!.id!);

      Provider.of<WalletProvider>(context, listen: false).loadWallets();

      _showSnackbar(context, 'Transazione eliminata con successo!');
      _navigateToHome(context);
    }
  }
}
