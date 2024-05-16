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
  String? _selectedWallet; // Updated
  int _selectedCategoryId = 0; 
  String? _selectedActionType; // Updated

  List<Category> categories = [
    Category(id: 1, name: 'Category 1'),
    Category(id: 2, name: 'Category 2'),
    Category(id: 3, name: 'Category 3'),
  ];
  List<String> actionTypes = ['Entrata', 'Uscita'];

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
        // Se ci sono più di un portafoglio, imposta il primo portafoglio come selezionato
        if (_wallets.length > 1) {
          _selectedWallet = _wallets[0].name!;
           actionTypes = ['Entrata', 'Uscita', 'Exchange'];
        }
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
            if (_wallets.isNotEmpty && _wallets.length > 1) // Aggiunto controllo per mostrare il form solo se ci sono più di un portafoglio
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
            DropdownButtonFormField<String>( // Form di selezione del tipo di azione
              value: _selectedActionType,
              onChanged: (newValue) {
                setState(() {
                  _selectedActionType = newValue;
                });
              },
              items: actionTypes.map((actionType) {
                return DropdownMenuItem(
                  value: actionType,
                  child: Text(actionType),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Tipo di Azione',
              ),
            ),
            DropdownButtonFormField<Category>(
              value: categories.firstWhere((category) => category.id == _selectedCategoryId, orElse: () => categories[0]),
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
            ElevatedButton(
              onPressed: () async {
                if (_selectedActionType != null && (_selectedWallet != null )) { // Controllo se sia stato selezionato un tipo di azione e un portafoglio (se presente)
                  // Creare una nuova transazione
                  Transaction newTransaction = Transaction(
                    name: _nameController.text,
                    categoryId: _selectedCategoryId,
                    date: DateTime.now().toString(),
                    value: double.parse(_valueController.text),
                    transactionId: _selectedWallet != null
                        ? _wallets.firstWhere((wallet) => wallet.name == _selectedWallet).id
                        : _wallets[0].id, // Usare il primo portafoglio se ne è selezionato uno
                 
                  );

                  // Inserire la transazione nel database
                  await dbHelper.insertTransaction(newTransaction);

                  // Cancella i campi di testo dopo l'inserimento
                  _nameController.clear();
                  _valueController.clear();

                  // Mostra un messaggio di successo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Transazione aggiunta con successo'),
                    ),
                  );
                } else {
                  // Mostra un messaggio di errore se il tipo di azione o il portafoglio non sono selezionati
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Seleziona un tipo di azione e un portafoglio'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Aggiungi Transazione'),
            ),
          ],
        ),
      ),
    );
  }
}
