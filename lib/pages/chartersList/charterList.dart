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
  List<FlSpot> _chartData = [];
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
    Provider.of<WalletProvider>(context, listen: false).loadValuta();
    _loadInitialData();
  }

  void _loadInitialData() async {
    await Provider.of<WalletProvider>(context, listen: false).loadWallets();
    if (Provider.of<WalletProvider>(context, listen: false)
        .wallets
        .isNotEmpty) {
      setState(() {
        _selectedWalletIndex = 0;
      });
      _fetchAndUpdateChartData(
          Provider.of<WalletProvider>(context, listen: false).wallets[0].id!);
    }
  }

  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! < 0) {
      // Swipe Left
      _changeButton(true);
    } else if (details.primaryVelocity! > 0) {
      // Swipe Right
      _changeButton(false);
    }
  }

  void _changeButton(bool forward) {
    final buttons = ['Today', 'Weekly', 'Monthly', 'Yearly'];
    int currentIndex = buttons.indexOf(_selectedButton);

    if (forward) {
      if (currentIndex < buttons.length - 1) {
        setState(() {
          _selectedButton = buttons[currentIndex + 1];
        });
      }
    } else {
      if (currentIndex > 0) {
        setState(() {
          _selectedButton = buttons[currentIndex - 1];
        });
      }
    }

    if (Provider.of<WalletProvider>(context, listen: false)
        .wallets
        .isNotEmpty) {
      _fetchAndUpdateChartData(
          Provider.of<WalletProvider>(context, listen: false)
              .wallets[_selectedWalletIndex]
              .id!);
    }
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
          Consumer<WalletProvider>(
            builder: (context, walletProvider, _) {
              if (walletProvider.wallets.isEmpty) {
                return Center(
                  child: Text(''),
                );
              }
              Wallet selectedWallet =
                  walletProvider.wallets[_selectedWalletIndex];
              String valuta = walletProvider.valuta;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...['Today', 'Weekly', 'Monthly', 'Yearly']
                            .map((period) => SizedBox(
                                  width: 93,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedButton = period;
                                      });
                                      _fetchAndUpdateChartData(
                                          selectedWallet.id!);
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      elevation: MaterialStateProperty.all(0),
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>((states) {
                                        return _selectedButton == period
                                            ? Color(0xffE63C3A)
                                            : Colors.transparent;
                                      }),
                                    ),
                                    child: Text(period,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: _selectedButton == period
                                                ? Colors.black
                                                : Color(0xffb3b3b3))),
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                    GestureDetector(
                      onHorizontalDragEnd: _handleSwipe,
                      child: Container(
                        height: 200,
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 16.0),
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: _fetchTransactions(
                              selectedWallet.id!, _selectedButton),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              if (!snapshot.hasData ||
                                  snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              Wallet selectedWallet = snapshot.data!['wallet'];
                              List<Transaction> transactions =
                                  snapshot.data!['transactions'];

                              _calculateChartData(transactions, selectedWallet);

                              return LineChart(
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
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              value.toInt().toString(),
                                              style: TextStyle(
                                                color: Color(0xff939393),
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Text(
                                              value.toInt().toString(),
                                              style: TextStyle(
                                                color: Color(0xff939393),
                                                fontSize: 10,
                                              ),
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
                                    border: Border.all(
                                        color: const Color(0xffe7e8ec),
                                        width: 1),
                                  ),
                                  minX: 0,
                                  maxX: transactions.length.toDouble(),
                                  minY: _chartData
                                      .map((spot) => spot.y)
                                      .reduce(Math.min)
                                      .floorToDouble(),
                                  maxY: _chartData
                                      .map((spot) => spot.y)
                                      .reduce(Math.max)
                                      .ceilToDouble(),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _chartData,
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
                              );
                            }
                          },
                        ),
                      ),
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
              );
            },
          ),
          SizedBox(height: 20),
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
                    Text("Transazioni per ${selectedWallet.name}:"),
                    SizedBox(height: 10),
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
    _chartData = [];

    double balance = wallet.balance ?? 0;

    double cumulativeSum = 0;

    _chartData.add(FlSpot(transactions.length.toDouble(), balance));

    for (int i = transactions.length - 1; i >= 0; i--) {
      cumulativeSum += transactions[i].value!;
      double currentBalance = balance - cumulativeSum;
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

  void _handleButtonPress(int index) {
    setState(() {
      _selectedWalletIndex = index;
    });
    _fetchAndUpdateChartData(
        Provider.of<WalletProvider>(context, listen: false).wallets[index].id!);
  }
}
