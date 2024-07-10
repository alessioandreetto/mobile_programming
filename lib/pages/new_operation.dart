import 'package:flutter/material.dart';
import '../model/database_model.dart';
import '../providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text == '') {
      return newValue;
    }

    final newValueText = newValue.text;
    if (double.tryParse(newValueText) == null) {
      return oldValue;
    }

    final List<String> parts = newValueText.split('.');
    if (parts.length > 1 && parts[1].length > decimalRange) {
      return oldValue;
    }
    return newValue;
  }
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
        dateController = TextEditingController(
            text: transaction?.date != null
                ? formatDate(DateTime.parse(transaction!.date!))
                : '');

  @override
  _NewTransactionPageState createState() => _NewTransactionPageState();

  static String formatDate(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  final dbHelper = DatabaseHelper();
  List<Wallet> _wallets = [];
  String _selectedWallet = '';
  int _selectedCategoryId = 0;
  int _selectedActionIndex = 0;
  DateTime? _selectedDate;
  bool _deleteButtonVisible = false;
  String _selectedWalletForExchangeOut = '';
  String _selectedWalletForExchangeIn = '';

  String? _initialName;
  String? _initialValue;
  DateTime? _initialDate;
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

  Map<int, Color> categoryColors = {
    0: Colors.red, // Categoria Auto
    1: Colors.blue, // Categoria Banca
    2: Colors.green, // Categoria Casa
    3: Colors.orange, // Categoria Intrattenimento
    4: Colors.purple, // Categoria Shopping
    5: Colors.yellow, // Categoria Viaggio
    6: Colors.brown, // Categoria Varie
  };

  Map<int, IconData> categoryIcons = {
    0: Icons.directions_car, // Categoria Auto
    1: Icons.account_balance, // Categoria Banca
    2: Icons.home, // Categoria Casa
    3: Icons.movie, // Categoria Intrattenimento
    4: Icons.shopping_cart, // Categoria Shopping
    5: Icons.airplanemode_active, // Categoria Viaggio
    6: Icons.category, // Categoria Varie
  };

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
      _initialDate = _selectedDate;
      _initialCategoryId = widget.transaction!.categoryId;
      _initialActionIndex = _selectedActionIndex;

      WidgetsBinding.instance!.addPostFrameCallback((_) {
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
          NewTransactionPage.formatDate(_selectedDate!);
      _initialName = '';
      _initialValue = '';
      _initialDate = _selectedDate;
      _initialCategoryId = 0;
      _initialActionIndex = Provider.of<WalletProvider>(context, listen: false)
              .getTipologiaMovimento()
          ? 1
          : 0;
      _selectedActionIndex = _initialActionIndex!;
    }
  }

  bool isDirty() {
    return widget.nameController.text != _initialName ||
        widget.valueController.text != _initialValue ||
        _selectedDate != _initialDate ||
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
        _selectedWalletForExchangeOut = _selectedWallet;
        _selectedWalletForExchangeIn = _selectedWallet;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime selectedDate = _selectedDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      locale: Locale('it', "IT"),
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.dateController.text =
            NewTransactionPage.formatDate(_selectedDate!);
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
                  'Hai delle modifiche non salvate. Sei sicuro di voler tornare indietro?'),
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
          return discardChanges == true;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.transaction != null
              ? 'Modifica transazione'
              : 'Nuova transazione'),
          actions: [
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                if (_selectedActionIndex == 2 &&
                    _selectedWalletForExchangeOut ==
                        _selectedWalletForExchangeIn) {
                  _showSnackbar(
                      context, 'Le wallet di scambio devono essere diverse.');
                  return;
                }

                final walletProvider =
                    Provider.of<WalletProvider>(context, listen: false);
                final selectedWallet =
                    walletProvider.wallets[walletProvider.selectedWalletIndex];

                final name = widget.nameController.text;
                final valueText = widget.valueController.text;
                if (name.isEmpty || valueText.isEmpty) {
                  _showSnackbar(
                      context, 'Per favore compila sia il nome che il valore.');
                  return;
                }

                final value = double.tryParse(valueText);
                if (value == null || value <= 0) {
                  _showSnackbar(context,
                      'Per favore inserisci un valore valido e maggiore di zero.');
                  return;
                }

                if (_selectedDate == null) {
                  _showSnackbar(
                      context, 'Per favore seleziona una data valida.');
                  return;
                }

                double finalValue =
                    _selectedActionIndex == 1 ? value * -1 : value;

                Transaction transaction = Transaction(
                  name: name,
                  value: finalValue,
                  date: _selectedDate!.toIso8601String(),
                  transactionId:
                      widget.transaction?.transactionId ?? selectedWallet.id!,
                  categoryId: _selectedCategoryId,
                );

                if (_selectedActionIndex == 2) {
                  Wallet walletOut = _wallets.firstWhere(
                      (wallet) => wallet.name == _selectedWalletForExchangeOut);
                  Wallet walletIn = _wallets.firstWhere(
                      (wallet) => wallet.name == _selectedWalletForExchangeIn);

                  transaction = Transaction(
                    name: name,
                    value: -value,
                    date: _selectedDate!.toIso8601String(),
                    transactionId: walletOut.id!,
                    categoryId: _selectedCategoryId,
                    relatedTransactionId: null,
                  );

                  Transaction relatedTransaction = Transaction(
                    name: name,
                    value: value,
                    date: _selectedDate!.toIso8601String(),
                    transactionId: walletIn.id!,
                    categoryId: _selectedCategoryId,
                    relatedTransactionId: null,
                  );

                  final relatedId =
                      await dbHelper.insertTransaction(relatedTransaction);

                  transaction = Transaction(
                    name: name,
                    value: -value,
                    date: _selectedDate!.toIso8601String(),
                    transactionId: walletOut.id!,
                    categoryId: _selectedCategoryId,
                    relatedTransactionId: relatedId,
                  );
                }

                if (widget.transaction != null) {
                  transaction.id = widget.transaction!.id;
                  await dbHelper.updateTransaction(transaction);
                } else {
                  await dbHelper.insertTransaction(transaction);
                }

                await walletProvider.refreshWallets();

                _showSnackbar(context, 'Transazione salvata con successo!');
                _navigateToHome(context);
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: widget.nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: widget.valueController,
                  decoration: InputDecoration(
                    labelText: 'Valore',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    DecimalTextInputFormatter(decimalRange: 2),
                  ],
                ),
                SizedBox(height: 16.0),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: widget.dateController,
                      decoration: InputDecoration(
                        labelText: 'Data',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedWallet,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedWallet = newValue!;
                    });
                  },
                  items:
                      _wallets.map<DropdownMenuItem<String>>((Wallet wallet) {
                    return DropdownMenuItem<String>(
                      value: wallet.name!,
                      child: Text(wallet.name!),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Wallet',
                  ),
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedCategoryId = newValue!;
                    });
                  },
                  items: categories
                      .map<DropdownMenuItem<int>>((Category category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(
                            categoryIcons[category.id],
                            color: categoryColors[category.id],
                          ),
                          SizedBox(width: 8.0),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                  ),
                ),
                SizedBox(height: 16.0),
                ToggleButtons(
                  children: actionTypes
                      .map<Widget>((String actionType) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(actionType),
                          ))
                      .toList(),
                  isSelected: List<bool>.generate(
                      actionTypes.length,
                      (int index) =>
                          index == _selectedActionIndex ? true : false),
                  onPressed: (int newIndex) {
                    setState(() {
                      _selectedActionIndex = newIndex;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                if (_selectedActionIndex == 2) ...[
                  Text('Wallet di uscita'),
                  DropdownButtonFormField<String>(
                    value: _selectedWalletForExchangeOut,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedWalletForExchangeOut = newValue!;
                      });
                    },
                    items:
                        _wallets.map<DropdownMenuItem<String>>((Wallet wallet) {
                      return DropdownMenuItem<String>(
                        value: wallet.name!,
                        child: Text(wallet.name!),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Wallet di uscita',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text('Wallet di entrata'),
                  DropdownButtonFormField<String>(
                    value: _selectedWalletForExchangeIn,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedWalletForExchangeIn = newValue!;
                      });
                    },
                    items:
                        _wallets.map<DropdownMenuItem<String>>((Wallet wallet) {
                      return DropdownMenuItem<String>(
                        value: wallet.name!,
                        child: Text(wallet.name!),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Wallet di entrata',
                    ),
                  ),
                ],
                SizedBox(height: 16.0),
                if (_deleteButtonVisible)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final bool? confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Conferma cancellazione'),
                          content: Text(
                              'Sei sicuro di voler cancellare questa transazione?'),
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
                        await dbHelper
                            .deleteTransaction(widget.transaction!.id!);
                        _showSnackbar(
                            context, 'Transazione eliminata con successo!');
                        _navigateToHome(context);
                      }
                    },
                    icon: Icon(Icons.delete),
                    label: Text('Cancella transazione'),
                    style: ElevatedButton.styleFrom(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
