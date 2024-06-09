import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/charts.dart';
import 'dart:math' as math;
import '../../model/database_model.dart';
import '../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../new_operation.dart';

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
    _selectedButton = 'Today';
    _selectedWalletIndex = 0;
    _pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charts page'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Today', 'Weekly', 'Monthly', 'Yearly'].map((period) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedButton = period;
                    _pageController.animateToPage(
                      ['Today', 'Weekly', 'Monthly', 'Yearly'].indexOf(period),
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
                          ? Color(0xffE63C3A)
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
                      ['Today', 'Weekly', 'Monthly', 'Yearly'][index];
                });
              },
              children: [
                _buildChart('Today'),
                _buildChart('Weekly'),
                _buildChart('Monthly'),
                _buildChart('Yearly'),
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
                    walletProvider.wallets[_selectedWalletIndex];
                String valuta = walletProvider.valuta;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0), // Aggiungi il padding a sinistra
                      child: Text("Transazioni per ${selectedWallet.name}:"),
                    ),
                    SizedBox(height: 10),
                    Consumer<WalletProvider>(
                      builder: (context, walletProvider, _) {
                        return Container(
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
                                    _handleButtonPress(index);
                                  },
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(0),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide(color: Colors.black),
                                    )),
                                    foregroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        return _selectedWalletIndex == index
                                            ? Colors.white
                                            : Colors.black;
                                      },
                                    ),
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        return _selectedWalletIndex == index
                                            ? Colors.black
                                            : Colors.white;
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
                                child: Text('No transactions available.'),
                              );
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
                                        leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  10), // Metà dell'altezza/larghezza per ottenere i bordi tondi
                              color: categoryColors[transaction.categoryId] ??
                                  Colors
                                      .grey, // Colore della categoria o grigio come fallback
                            ),
                            child: Icon(
                              categoryIcons[transaction.categoryId] ??
                                  Icons
                                      .category, // Icona della categoria o categoria come fallback
                              color: Colors.white, // Colore dell'icona
                            ),
                          ),
                                      title: Text(transaction.name ?? ''),
                                      subtitle: Text(
                                          "Data: $formattedDate, Valore: ${transaction.value} $valuta"),
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
        Wallet selectedWallet = walletProvider.wallets[_selectedWalletIndex];
        String valuta = walletProvider.valuta;

        return FutureBuilder<Map<String, dynamic>>(
          future: _fetchTransactions(selectedWallet.id!, period),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Transaction> transactions = snapshot.data!['transactions'];
              List<FlSpot> chartData =
                  _calculateChartData(transactions, selectedWallet);

              return Padding(
                padding:
                    const EdgeInsets.all(16.0), // Add padding around the chart
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Color(0xffe7e8ec),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Color(0xffe7e8ec),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            // Mostra i titoli solo nei punti corrispondenti alle transazioni
                            if (chartData.any((spot) => spot.x == value)) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Color(0xff939393),
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            } else {
                              return Container(); // Non mostrare nulla se non è un punto della transazione
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40, // Aumenta la larghezza riservata
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Color(0xff939393),
                                  fontSize: 10,
                                  height: 1.2, // Imposta l'altezza della linea
                                ),
                                textAlign: TextAlign.center, // Centra il testo
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border:
                          Border.all(color: const Color(0xffe7e8ec), width: 1),
                    ),
                    minX: 0,
                    maxX: transactions.length.toDouble(),
                    minY: chartData
                        .map((spot) => spot.y)
                        .reduce(math.min)
                        .floorToDouble(),
                    maxY: chartData
                        .map((spot) => spot.y)
                        .reduce(math.max)
                        .ceilToDouble(),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xff4af699),
                            Color(0xff23b6e6),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff4af699).withOpacity(0.4),
                              Color(0xff23b6e6).withOpacity(0.4),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  // Method to calculate chart data
  List<FlSpot> _calculateChartData(
      List<Transaction> transactions, Wallet wallet) {
    List<FlSpot> chartData = [];

    double balance = wallet.balance ?? 0;
    double cumulativeSum = 0;

    chartData.add(FlSpot(transactions.length.toDouble(), balance));

    for (int i = transactions.length - 1; i >= 0; i--) {
      cumulativeSum += transactions[i].value!;
      double currentBalance = balance - cumulativeSum;
      chartData.insert(0, FlSpot(i.toDouble(), currentBalance));
    }

    return chartData;
  }

  // Method to format DateTime to desired format
  String _formatDateTime(DateTime dateTime) {
    final formattedDate =
        "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}";
    final formattedTime =
        "${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}";
    return "$formattedDate";
  }

  // Method to fetch transactions
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

  // Method to fetch negative transactions
  Future<List<Transaction>> _fetchNegativeTransactions(
      int walletId, String selectedButton) async {
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

  // Method to handle button press
  void _handleButtonPress(int index) {
    setState(() {
      _selectedWalletIndex = index;
    });
  }

  // Method to navigate to transaction detail page
  void _navigateToTransactionDetail(
      BuildContext context, Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTransactionPage(transaction: transaction),
      ),
    );
  }

  // Helper method to format two digits
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
