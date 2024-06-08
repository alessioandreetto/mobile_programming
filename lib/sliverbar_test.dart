import 'package:flutter/material.dart';
import '../providers/wallet_provider.dart';
import 'package:provider/provider.dart'; // Assicurati di importare correttamente il pacchetto provider
import '../model/database_model.dart'; // Assicurati di importare correttamente la tua classe di gestione del database
import 'dart:math' as Math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => WalletProvider(), // Assicurati di fornire correttamente il WalletProvider
        child: SliverTest(),
      ),
    );
  }
}

class SliverTest extends StatefulWidget {
  @override
  _SliverTestState createState() => _SliverTestState();
}

class _SliverTestState extends State<SliverTest> {
  late List<Transaction> transactions = [];
  late int _selectedWalletIndex = 0; // Assicurati di dichiarare correttamente _selectedWalletIndex
  bool _showExpenses = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions(_selectedWalletIndex); // Carica le transazioni del portafoglio iniziale
  }

Future<void> _loadTransactions(int walletIndex) async {
  try {
    List<Transaction> loadedTransactions = await DatabaseHelper()
        .getTransactionsForWallet(walletIndex + 1); // Aggiungi 1 perché gli indici iniziano da 0
    
    if (_showExpenses) {
      // Filtra solo le transazioni di uscita
      loadedTransactions = loadedTransactions
          .where((transaction) => transaction.value! < 0)
          .toList();
    } else {
      // Filtra solo le transazioni di entrata
      loadedTransactions = loadedTransactions
          .where((transaction) => transaction.value! >= 0)
          .toList();
    }

    setState(() {
      transactions = loadedTransactions;
    });
  } catch (e) {
    print('Errore durante il caricamento delle transazioni: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    var walletProvider = Provider.of<WalletProvider>(context); // Assicurati di ottenere correttamente il provider

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: true,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portafoglio',
                  style: TextStyle(fontSize: 16.0),
                ),
                Text(
                  'di',
                  style: TextStyle(fontSize: 12.0),
                ),
                Text(
                  'Utente',
                  style: TextStyle(fontSize: 12.0),
                ),
              ],
            ),
            floating: true,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.pink[100],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverPersistentHeaderDelegate(
              
              minHeight: 100.0,
              maxHeight: 100.0,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Transazioni per ${walletProvider.wallets[_selectedWalletIndex].name}:"),
                    DropdownButton<bool>(
                      value: _showExpenses,
                      onChanged: (value) {
                        setState(() {
                          _showExpenses = value!;
                          _loadTransactions(_selectedWalletIndex);
                        });
                      },
                      items: [
                        DropdownMenuItem<bool>(
                          value: true,
                          child: Text('Mostra Uscite'),
                        ),
                        DropdownMenuItem<bool>(
                          value: false,
                          child: Text('Mostra Entrate'),
                        ),
                      ],
                    ),
                  ],
                ),
                    Container(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: walletProvider.wallets.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedWalletIndex = index;
                                });
                                _loadTransactions(index); // Carica le transazioni del nuovo portafoglio selezionato
                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(0),
                                shape:
                                    MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(color: Colors.black),
                                )),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    return _selectedWalletIndex == index
                                        ? Colors.white
                                        : Colors.black;
                                  },
                                ),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    return _selectedWalletIndex == index
                                        ? Colors.black
                                        : Colors.white;
                                  },
                                ),
                              ),
                              child: Text(walletProvider.wallets[index].name!),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final Transaction transaction = transactions[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 100.0,
                    child: Center(child: Text(transaction.name!)),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffb3b3b3),
                      ),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                );
              },
              childCount: transactions.length, // Numero di transazioni
            ),
          ),
          
        ],
      ),
    );
  }
}

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverPersistentHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverPersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

