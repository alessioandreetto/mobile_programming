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
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        return _selectedButton == 'Today' ? Color(0xffE63C3A) : Colors.transparent;
                      }),
                    ),
                    child: Text('Today', style: TextStyle(fontSize: 12, color: _selectedButton == 'Today' ? Colors.black : Color(0xffb3b3b3))),
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
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        return _selectedButton == 'Weekly' ? Color(0xffE63C3A) : Colors.transparent;
                      }),
                    ),
                    child: Text('Weekly', style: TextStyle(fontSize: 12, color: _selectedButton == 'Weekly' ? Colors.black : Color(0xffb3b3b3))),
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
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        return _selectedButton == 'Monthly' ? Color(0xffE63C3A) : Colors.transparent;
                      }),
                    ),
                    child: Text('Monthly', style: TextStyle(fontSize: 12, color: _selectedButton == 'Monthly' ? Colors.black : Color(0xffb3b3b3))),
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
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        return _selectedButton == 'Yearly' ? Color(0xffE63C3A) : Colors.transparent;
                      }),
                    ),
                    child: Text('Yearly', style: TextStyle(fontSize: 12, color: _selectedButton == 'Yearly' ? Colors.black : Color(0xffb3b3b3))),
                  ),
                ),
              ],
            ),
                   /*  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nome Wallet: ${selectedWallet.name}"),
                            Text("Bilancio: ${selectedWallet.balance} €"),
                            if (_selectedCategory != null)
                              Text("$nomeCategoria :  $valoreCategoria €"),
                          ],
                        ),
                        FutureBuilder<List<Transaction>>(
                          future: _fetchNegativeTransactions(selectedWallet.id!),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(child: Text('No transactions found'));
                            } else {
                              List<Transaction> transactions = snapshot.data!;
                              Map<String, double> categoryAmounts =
                                  _calculateCategoryAmounts(transactions);
                              return GestureDetector(
                                onTapUp: (details) {
                                  _handlePieChartTap(details, categoryAmounts);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 35.0),
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    child: PieChart(
                                      PieChartData(
                                        sections: _createPieChartSections(
                                            categoryAmounts),
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ), */
                     Container(
            height: 200,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _fetchTransactions(selectedWallet.id!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  Wallet selectedWallet = snapshot.data!['wallet'];
                  List<Transaction> transactions = snapshot.data!['transactions'];

                  // Calcoliamo i dati per il grafico
                  _calculateChartData(transactions, selectedWallet);

                  return LineChart(
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
                        future: _fetchNegativeTransactions(selectedWallet.id!),
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

  Future<List<Transaction>> _fetchNegativeTransactions(int walletId) async {
    List<Transaction> transactions =
        await DatabaseHelper().getTransactionsForWallet(walletId);
    return transactions.toList();
  }

  Future<Map<String, dynamic>> _fetchTransactions(int walletId) async {
    Map<String, dynamic> result = {};

    Wallet wallet = await DatabaseHelper().getWalletById(walletId);
    result['wallet'] = wallet;

    List<Transaction> transactions =
        await DatabaseHelper().getTransactionsForWallet(walletId);
    result['transactions'] = transactions;

    return result;
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

  Map<String, double> _calculateCategoryAmounts(
    List<Transaction> transactions,
  ) {
    Map<String, double> categoryAmounts = {};

    transactions.forEach((transaction) {
      final categoryId = transaction.categoryId.toString();
      final value = transaction.value ?? 0.0;
      if (categoryAmounts.containsKey(categoryId)) {
        categoryAmounts[categoryId] =
            (categoryAmounts[categoryId] ?? 0) + value;
      } else {
        categoryAmounts[categoryId] = value;
      }
    });

    return categoryAmounts;
  }

  List<PieChartSectionData> _createPieChartSections(
    Map<String, double> categoryAmounts,
  ) {
    List<Color> fixedColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.brown,
    ];

    List<PieChartSectionData> sections = [];
    int index = 0;

    categoryAmounts.forEach((category, amount) {
      bool isSelected = _selectedCategory == category;
      sections.add(PieChartSectionData(
        color: fixedColors[int.parse(category)],
        value: amount,
        title: '',
        radius: isSelected ? 100 : 90,
      ));

      index++;
    });

    return sections;
  }



  void _handlePieChartTap(
      TapUpDetails details, Map<String, double> categoryAmounts) {
    final touchPos = details.localPosition;
    final touchAngle = _getAngle(touchPos);
    final categoryIndex = _getTouchedCategoryIndex(touchAngle, categoryAmounts);

    setState(() {
      String tappedCategory = categoryAmounts.keys.elementAt(categoryIndex);
      if (_selectedCategory == tappedCategory) {
        _selectedCategory = null;
      } else {
        _selectedCategory = tappedCategory;
        nomeCategoria = categories[int.parse(tappedCategory) - 1].name;
        valoreCategoria = categoryAmounts[tappedCategory]!;
      }
    });
  }

  double _getAngle(Offset position) {
    final centerX = 75.0;
    final centerY = 75.0;
    final dx = position.dx - centerX;
    final dy = position.dy - centerY;
    final angle = (Math.atan2(dy, dx) * 180 / Math.pi + 360) % 360;
    return angle;
  }

  int _getTouchedCategoryIndex(
      double angle, Map<String, double> categoryAmounts) {
    final totalAmount = _getTotalAmount(categoryAmounts);
    double currentAngle = 0.0;

    int index = 0;
    for (var amount in categoryAmounts.values) {
      final sweepAngle = (amount / totalAmount) * 360;
      if (angle >= currentAngle && angle <= currentAngle + sweepAngle) {
        return index;
      }
      currentAngle += sweepAngle;
      index++;
    }
    return -1;
  }

  double _getTotalAmount(Map<String, double> categoryAmounts) {
    double total = 0;
    categoryAmounts.values.forEach((amount) {
      total += amount;
    });
    return total;
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
}
