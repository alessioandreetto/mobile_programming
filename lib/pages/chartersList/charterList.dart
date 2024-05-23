import 'package:flutter/material.dart';
import 'dart:math' as Math;
import '../../model/database_model.dart';
import '../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../new_operation.dart';

class ChartsList extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsList> {
  late String _selectedButton;
  late int _selectedWalletIndex;
  List<FlSpot> _chartData = []; // Lista per i dati del grafico

  @override
  void initState() {
    super.initState();
    _selectedButton = 'Today'; // Inizialmente selezionato 'Today'
    _selectedWalletIndex = 0;
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 85,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedButton = 'Today';
                      });
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
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
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
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
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
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
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
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
          ),
          // Aggiungi qui il grafico LineChart
          Container(
            height: 200,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _chartData, // Utilizziamo i dati calcolati per il grafico
                    isCurved: true,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          // Aggiungi qui i pulsanti per selezionare il portafoglio
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
                          });
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
          // Aggiungi qui la lista delle transazioni
          Expanded(
            child: Consumer<WalletProvider>(
              builder: (context, walletProvider, _) {
                Wallet selectedWallet =
                    walletProvider.wallets[_selectedWalletIndex];
                return FutureBuilder<List<Transaction>>(
                  future: _fetchTransactions(selectedWallet.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('No transactions found'),
                      );
                    } else {
                      List<Transaction> transactions = snapshot.data!;
                      
                      // Calcoliamo i dati per il grafico
                      _calculateChartData(transactions);

                      return ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Transaction>> _fetchTransactions(int walletId) async {
    List<Transaction> transactions =
        await DatabaseHelper().getTransactionsForWallet(walletId);
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

  void _navigateToTransactionDetail(
      BuildContext context, Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTransactionPage(transaction: transaction),
      ),
    );
  }

  void _calculateChartData(List<Transaction> transactions) {
    // Resetta la lista dei dati del grafico
    _chartData = [];

    // Aggiunge i dati delle transazioni alla lista dei dati del grafico
    for (int i = 0; i < transactions.length; i++) {
      _chartData.add(FlSpot(i.toDouble(), transactions[i].value!));
    }
  }
}

