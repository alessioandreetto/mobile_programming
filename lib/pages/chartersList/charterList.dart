import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/charts.dart';
import 'dart:math' as Math;
import '../../model/database_model.dart';
import '../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../new_operation.dart';

class ChartsList extends StatefulWidget {
  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<ChartsList> {
  late int _selectedWalletIndex;
  late String _selectedButton;
  double valoreCategoria = 0;
  String nomeCategoria = '';
  String? _selectedCategory;
  List<FlSpot> _chartData = []; // Lista per i dati del grafico
  late Future<Map<String, dynamic>> _transactionsFuture;

  List<Category> categories = [
    Category(id: 1, name: 'Auto'),
    Category(id: 2, name: 'Banca'),
    Category(id: 3, name: 'Casa'),
    Category(id: 4, name: 'Intrattenimento'),
    Category(id: 5, name: 'Shopping'),
    Category(id: 6, name: 'Viaggio'),
    Category(id: 7, name: 'Varie'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedButton = 'Today';
    _selectedWalletIndex = 0;
    _selectedCategory = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome User'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<WalletProvider>(
            builder: (context, walletProvider, _) {
              Wallet selectedWallet =
                  walletProvider.wallets[_selectedWalletIndex];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 85,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedButton = 'Today';
                              });
                              _fetchAndUpdateChartData(selectedWallet.id!);
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) {
                                return _selectedButton == 'Today'
                                    ? Color(0xffE63C3A)
                                    : Colors.transparent;
                              }),
                            ),
                            child: Text('Today',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _selectedButton == 'Today'
                                        ? Colors.black
                                        : Color(0xffb3b3b3))),
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedButton = 'Weekly';
                              });
                              _fetchAndUpdateChartData(selectedWallet.id!);
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) {
                                return _selectedButton == 'Weekly'
                                    ? Color(0xffE63C3A)
                                    : Colors.transparent;
                              }),
                            ),
                            child: Text('Weekly',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _selectedButton == 'Weekly'
                                        ? Colors.black
                                        : Color(0xffb3b3b3))),
                          ),
                        ),
                        SizedBox(
                          width: 95,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedButton = 'Monthly';
                              });
                              _fetchAndUpdateChartData(selectedWallet.id!);
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) {
                                return _selectedButton == 'Monthly'
                                    ? Color(0xffE63C3A)
                                    : Colors.transparent;
                              }),
                            ),
                            child: Text('Monthly',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _selectedButton == 'Monthly'
                                        ? Colors.black
                                        : Color(0xffb3b3b3))),
                          ),
                        ),
                        SizedBox(
                          width: 85,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedButton = 'Yearly';
                              });
                              _fetchAndUpdateChartData(selectedWallet.id!);
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) {
                                return _selectedButton == 'Yearly'
                                    ? Color(0xffE63C3A)
                                    : Colors.transparent;
                              }),
                            ),
                            child: Text('Yearly',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _selectedButton == 'Yearly'
                                        ? Colors.black
                                        : Color(0xffb3b3b3))),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 200,
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 16.0),
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: _fetchTransactions(selectedWallet.id!, _selectedButton),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            Wallet selectedWallet = snapshot.data!['wallet'];
                            List<Transaction> transactions =
                                snapshot.data!['transactions'];

                            // Calcoliamo i dati per il grafico
                            _calculateChartData(transactions, selectedWallet);

                            return LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots:
                                        _chartData, // Utilizziamo i dati calcolati per il grafico
                                    isCurved: true,
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20),
          Container(
            height: 50,
            child: Consumer<WalletProvider>(
              builder: (context, walletProvider, _) {
                List<Wallet> wallets = walletProvider.wallets;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedWalletIndex = index;
                            _selectedCategory = null;
                          });
                          _fetchAndUpdateChartData(wallets[index].id!);
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
                        child: Text(wallets[index].name!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Consumer<WalletProvider>(
              builder: (context, walletProvider, _) {
                Wallet selectedWallet =
                    walletProvider.wallets[_selectedWalletIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Transazioni per ${selectedWallet.name}:"),
                    SizedBox(height: 10),
                    Expanded(
                      child: FutureBuilder<List<Transaction>>(
                        future: _fetchNegativeTransactions(selectedWallet.id!, _selectedButton),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Text('No transactions found'),
                            );
                          } else {
                            List<Transaction> transactions = snapshot.data!;
                            if (_selectedCategory != null) {
                              transactions = transactions
                                  .where((transaction) =>
                                      transaction.categoryId.toString() ==
                                      _selectedCategory)
                                  .toList();
                            }
                            return ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction =
                                    transactions.reversed.toList()[index];
                                final date = DateTime.parse(transaction.date!);
                                final formattedDate = _formatDateTime(date);
                                return GestureDetector(
                                  onTap: () {
                                    _navigateToTransactionDetail(
                                        context, transaction);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        bottom: 10, left: 10, right: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xffb3b3b3),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: ListTile(
                                      title: Text(transaction.name ?? ''),
                                      subtitle: Text(
                                          "Data: $formattedDate, Valore: ${transaction.value} €"),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchTransactions(int walletId, String selectedButton) async {
    Map<String, dynamic> result = {};

    Wallet wallet = await DatabaseHelper().getWalletById(walletId);
    result['wallet'] = wallet;

    List<Transaction> transactions =
        await _fetchNegativeTransactions(walletId, selectedButton);
    result['transactions'] = transactions;

    return result;
  }

Future<List<Transaction>> _fetchNegativeTransactions(int walletId, String selectedButton) async {
  // Recupera il periodo selezionato
  DateTime startDate = DateTime.now();
  DateTime now = DateTime.now();
  if (selectedButton == 'Today') {
    startDate = DateTime(now.year, now.month, now.day);
  } else if (selectedButton == 'Weekly') {
    startDate = now.subtract(Duration(days: now.weekday - 1));
  } else if (selectedButton == 'Monthly') {
    startDate = DateTime(now.year, now.month, 1);
  } else if (selectedButton == 'Yearly') {
    startDate = DateTime(now.year, 1, 1);
  }

  // Recupera le transazioni in base al periodo selezionato
  List<Transaction> transactions =
      await DatabaseHelper().getTransactionsForWallet(walletId);

  // Filtra le transazioni in base alla data e al periodo selezionato
  transactions = transactions.where((transaction) {
    DateTime transactionDate = DateTime.parse(transaction.date!);
    return transactionDate.isAfter(startDate.subtract(Duration(days: 1))) &&
        transactionDate.isBefore(now.add(Duration(days: 1)));
  }).toList();

  // Ordina le transazioni per data
  transactions.sort((a, b) => DateTime.parse(a.date!).compareTo(DateTime.parse(b.date!)));

  return transactions;
}


  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String _formatDateTime(DateTime dateTime) {
    final formattedDate =
        "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}";
    final formattedTime =
        "${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}";
    return "$formattedDate";
  }

  void _calculateChartData(List<Transaction> transactions, Wallet wallet) {
    // Resetta la lista dei dati del grafico
    _chartData = [];

    // Inizializza il saldo con il saldo attuale del portafoglio
    double balance = wallet.balance ?? 0;

    // Inizializza la somma cumulativa delle transazioni a zero
    double cumulativeSum = 0;

    // Aggiunge il saldo attuale come ultimo punto nel grafico
    _chartData.add(FlSpot(transactions.length.toDouble(), balance));

    // Calcola il saldo retroattivamente partendo dal saldo attuale
    for (int i = transactions.length - 1; i >= 0; i--) {
      // Aggiunge il valore della transazione alla somma cumulativa
      cumulativeSum += transactions[i].value!;
      // Calcola il saldo retroattivo sottraendo la somma cumulativa dal saldo attuale
      double currentBalance = balance - cumulativeSum;
      // Aggiunge il saldo retroattivo come punto nel grafico
      _chartData.insert(0, FlSpot(i.toDouble(), currentBalance));
    }
  }

  void _navigateToTransactionDetail(
      BuildContext context, Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTransactionPage(transaction: transaction),
      ),
    );
  }

  void _fetchAndUpdateChartData(int walletId) {
    setState(() {
      _transactionsFuture = _fetchTransactions(walletId, _selectedButton);
    });
  }
}
