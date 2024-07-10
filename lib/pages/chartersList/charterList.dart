import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/new_operation.dart';
import 'dart:math' as math;
import '../../model/database_model.dart';
import '../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartsList extends StatefulWidget {
  @override
  _ChartsListState createState() => _ChartsListState();
}

class _ChartsListState extends State<ChartsList> {
  late int _selectedWalletIndex;
  late String _selectedButton;
  late PageController _pageController;

  Map<int, Color> categoryColors = {
    0: Colors.red, // Categoria Auto
    1: Colors.blue, // Categoria Banca
    2: Colors.green, // Categoria Casa
    3: Colors.orange, // Categoria Intrattenimento
    4: Colors.purple, // Categoria Shopping
    5: Colors.yellow, // Categoria Viaggio
    6: Colors.brown, // Categoria Varie
  };

  List<Category> categories = [
    Category(id: 1, name: 'Auto'),
    Category(id: 2, name: 'Banca'),
    Category(id: 3, name: 'Casa'),
    Category(id: 4, name: 'Intrattenimento'),
    Category(id: 5, name: 'Shopping'),
    Category(id: 6, name: 'Viaggio'),
    Category(id: 7, name: 'Varie'),
  ];

  Map<int, IconData> categoryIcons = {
    0: Icons.directions_car, // Categoria Auto
    1: Icons.account_balance, // Categoria Banca
    2: Icons.home, // Categoria Casa
    3: Icons.movie, // Categoria Intrattenimento
    4: Icons.shopping_cart, // Categoria Shopping
    5: Icons.airplanemode_active, // Categoria Viaggio
    6: Icons.category, // Categoria Varie
  };

  @override
  void initState() {
    super.initState();
    _selectedButton = 'Oggi';
    _selectedWalletIndex = 0;
    _pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Grafico finanze', style: TextStyle(fontSize: 25)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Oggi', 'Settimana', 'Mese', 'Anno'].map((period) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedButton = period;
                    _pageController.animateToPage(
                      ['Oggi', 'Settimana', 'Mese', 'Anno'].indexOf(period),
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  });
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  elevation: MaterialStateProperty.all(0),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      return _selectedButton == period
                          ? Colors.blue
                          : Colors.transparent;
                    },
                  ),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedButton == period
                        ? Colors.black
                        : Color(0xffb3b3b3),
                  ),
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedButton =
                      ['Oggi', 'Settimana', 'Mese', 'Anno'][index];
                });
              },
              children: [
                _buildChart('Oggi'),
                _buildChart('Settimana'),
                _buildChart('Mese'),
                _buildChart('Anno'),
              ],
            ),
          ),
          Expanded(
            child: Consumer<WalletProvider>(
              builder: (context, walletProvider, _) {
                if (walletProvider.wallets.isEmpty) {
                  return Center(
                    child: Text('Nessun portafoglio disponibile'),
                  );
                }
                Wallet selectedWallet =
                    walletProvider.wallets[walletProvider.selectedWalletIndex];
                String valuta = walletProvider.valuta;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<WalletProvider>(
                      builder: (context, walletProvider, _) {
                        return Container(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: walletProvider.wallets.length,
                            itemBuilder: (context, index) {
                              bool isSelected =
                                  walletProvider.selectedWalletIndex == index;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _handleButtonPress(index);
                                    walletProvider
                                        .updateSelectedWalletIndex(index);
                                  },
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(0),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        side: BorderSide(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    foregroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (Theme.of(context).brightness ==
                                            Brightness.light) {
                                          return walletProvider
                                                          .selectedWalletIndex +
                                                      1 ==
                                                  walletProvider
                                                      .wallets[index].id!
                                              ? Colors.white
                                              : Colors.black;
                                        } else {
                                          return walletProvider
                                                          .selectedWalletIndex +
                                                      1 ==
                                                  walletProvider
                                                      .wallets[index].id!
                                              ? Colors.black
                                              : Colors.white;
                                        }
                                      },
                                    ),
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (Theme.of(context).brightness ==
                                            Brightness.light) {
                                          return walletProvider
                                                          .selectedWalletIndex +
                                                      1 ==
                                                  walletProvider
                                                      .wallets[index].id!
                                              ? Colors.black
                                              : Colors.white;
                                        } else {
                                          return walletProvider
                                                          .selectedWalletIndex +
                                                      1 ==
                                                  walletProvider
                                                      .wallets[index].id!
                                              ? Colors.white
                                              : Colors.black;
                                        }
                                      },
                                    ),
                                    textStyle: MaterialStateProperty
                                        .resolveWith<TextStyle>(
                                      (Set<MaterialState> states) {
                                        return TextStyle(
                                          color: walletProvider
                                                          .selectedWalletIndex +
                                                      1 ==
                                                  walletProvider
                                                      .wallets[index].id!
                                              ? (Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.white
                                                  : Colors.black)
                                              : (Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.black
                                                  : Colors.white),
                                        );
                                      },
                                    ),
                                  ),
                                  child:
                                      Text(walletProvider.wallets[index].name!),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8.0 , bottom: 10),
                      child: Text(
                        "Transazioni per ${selectedWallet.name}:",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<Transaction>>(
                        future: _fetchNegativeTransactions(
                            selectedWallet.id!, _selectedButton),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.connectionState ==
                                  ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            List<Transaction> transactions = snapshot.data!;

                            if (transactions.isEmpty) {
                              return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          
                            Icon(Icons.search_off, size: 48.0),
                            Text(
                              'Nessuna transazione',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ],
                        ),
                      );
                            }

                            return ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction =
                                    transactions.reversed.toList()[index];
                                final date = DateTime.parse(transaction.date!);
                                final formattedDate = _formatDateTime(date);
                                return Slidable(
                                  key: ValueKey(index),
                                  startActionPane: ActionPane(
                                    extentRatio: 0.25,
                                    motion: ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        borderRadius: BorderRadius.circular(10),
                                        padding: EdgeInsets.all(20),
                                        onPressed: (context) {
                                          _deleteTransaction(
                                              transaction, walletProvider);
                                          setState(() {
                                            transactions.removeAt(index);
                                          });
                                        },
                                        backgroundColor: Theme.of(context).brightness ==
                                    Brightness.light
                                ? Colors.white: Colors.black,
                            foregroundColor: Colors.red,
                                        icon: Icons.delete,
                                        label: 'Elimina',
                                      ),
                                    ],
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      _navigateToTransactionDetail(
                                          context, transaction);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5.0, right: 5.0, bottom: 5.0),
                                      child: Card(
                                        /*    decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.white
                                              : Colors
                                                  .black, // Imposta il colore di sfondo in base alla modalità
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 3,
                                              blurRadius: 5,
                                              offset: Offset(0,
                                                  1), // changes position of shadow
                                            ),
                                          ],
                                        ), */
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.all(
                                                  8), // Aggiunto margin qui
                                              padding: EdgeInsets.all(12),
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: categoryColors[
                                                        transaction
                                                            .categoryId] ??
                                                    Colors.grey,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  categoryIcons[transaction
                                                          .categoryId] ??
                                                      Icons.category,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  /* Text(
                                                    transaction.name ?? '',
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ), */

                                                  RichText(
                                                    text: TextSpan(
                                                      text: transaction.name,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: (Theme.of(
                                                                        context)
                                                                    .brightness ==
                                                                Brightness.light
                                                            ? Colors.black
                                                            : Colors.white),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                          text: ' - ' +
                                                              categories[int.parse(
                                                                      transaction
                                                                          .categoryId
                                                                          .toString())]
                                                                  .name,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            color: (Theme.of(
                                                                            context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .light
                                                                ? Colors.black
                                                                : Colors.white),
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(formattedDate,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.light
                                                            ? Colors
                                                                .black // Colore del testo per la modalità chiara
                                                            : Colors
                                                                .white, // Colore del testo per la modalità scura
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "${transaction.value} ${walletProvider.valuta}",
                                                style: TextStyle(
                                                  color: transaction.value! >= 0
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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

  Widget _buildChart(String period) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, _) {
        if (walletProvider.wallets.isEmpty) {
          return Center(
            child: Text('Nessun portafoglio disponibile'),
          );
        }
        Wallet selectedWallet =
            walletProvider.wallets[walletProvider.selectedWalletIndex];
        String valuta = walletProvider.valuta;

        return FutureBuilder<Map<String, dynamic>>(
          future: _fetchTransactions(selectedWallet.id!, period),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Transaction> transactions = snapshot.data!['transactions'];
              List<ChartSampleData> chartData =
                  _calculateChartData(transactions, selectedWallet);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SfCartesianChart(
                  primaryXAxis: NumericAxis(interval: 1),
                  primaryYAxis: NumericAxis(),
                  series: <LineSeries<ChartSampleData, num>>[
                    LineSeries<ChartSampleData, num>(
                      dataSource: chartData,
                      xValueMapper: (ChartSampleData data, _) => data.x,
                      yValueMapper: (ChartSampleData data, _) => data.y,
                      dataLabelMapper: (ChartSampleData data, _) {
                        // Calcola il bilancio parziale
                        double partialBalance = data.y;
                        // Ottieni il valore della transazione
                        double transactionValue = data.transactionValue;
                        // Controlla se il valore della transazione è double.nan
                        if (transactionValue.isNaN) {
                          return '${partialBalance.toStringAsFixed(2)} ${walletProvider.valuta}';
                        } else {
                          // Formatta il testo dell'etichetta per includere sia il bilancio parziale che il valore della transazione
                          return '${partialBalance.toStringAsFixed(2)} ${walletProvider.valuta}\n${transactionValue.toStringAsFixed(2)} ${walletProvider.valuta}';
                        }
                      },
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  List<ChartSampleData> _calculateChartData(
      List<Transaction> transactions, Wallet wallet) {
    List<ChartSampleData> chartData = [];

    // Calculate the initial balance by summing up all transaction values
    double totalTransactionValue = transactions.fold(0, (acc, transaction) {
      return acc + (transaction.value ?? 0);
    });

    // Initial balance is the wallet balance minus total transaction value
    double initialBalance = (wallet.balance ?? 0) - totalTransactionValue;

    // Add initial balance as the first data point regardless of transactions
    chartData.add(ChartSampleData(0, initialBalance,
        double.nan)); // Use double.nan for the first transaction value

    // Loop through each transaction and update the balance accordingly
    double balance = initialBalance;
    for (int i = 0; i < transactions.length; i++) {
      // Get the value of the transaction
      double transactionValue = transactions[i].value!;
      // Calculate the new balance after applying the transaction
      balance += transactionValue; // Add or subtract transaction value
      // Add the data point with the updated balance
      chartData.add(ChartSampleData(i + 1, balance, transactionValue));
    }

    return chartData;
  }

  String _formatDateTime(DateTime dateTime) {
    final formattedDate =
        "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}";
    final formattedTime =
        "${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}";
    return "$formattedDate";
  }

  Future<Map<String, dynamic>> _fetchTransactions(
      int walletId, String selectedButton) async {
    Map<String, dynamic> result = {};

    Wallet wallet = await DatabaseHelper().getWalletById(walletId);
    result['wallet'] = wallet;

    List<Transaction> transactions =
        await _fetchNegativeTransactions(walletId, selectedButton);
    result['transactions'] = transactions;

    return result;
  }

  Future<List<Transaction>> _fetchNegativeTransactions(
      int walletId, String selectedButton) async {
    DateTime startDate = DateTime.now();
    DateTime now = DateTime.now();
    if (selectedButton == 'Oggi') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (selectedButton == 'Settimana') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
    } else if (selectedButton == 'Mese') {
      startDate = DateTime(now.year, now.month, 1);
    } else if (selectedButton == 'Anno') {
      startDate = DateTime(now.year, 1, 1);
    }

    List<Transaction> transactions =
        await DatabaseHelper().getTransactionsForWallet(walletId);

    transactions = transactions.where((transaction) {
      DateTime transactionDate = DateTime.parse(transaction.date!);
      return transactionDate.isAfter(startDate.subtract(Duration(days: 1))) &&
          transactionDate.isBefore(now.add(Duration(days: 1)));
    }).toList();

    transactions.sort(
        (a, b) => DateTime.parse(a.date!).compareTo(DateTime.parse(b.date!)));

    return transactions;
  }

  void _handleButtonPress(int index) {
    setState(() {
      _selectedWalletIndex = index;
    });
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

  void _deleteTransaction(
      Transaction transaction, WalletProvider walletProvider) async {
    double deletedTransactionValue = transaction.value ?? 0.0;
    await DatabaseHelper().deleteTransaction(transaction.id!);
    walletProvider.refreshWallets();
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class ChartSampleData {
  final double x;
  final double y;
  final double
      transactionValue; // Aggiunto valore della transazione per il punto dati del grafico

  ChartSampleData(this.x, this.y, this.transactionValue);
}
