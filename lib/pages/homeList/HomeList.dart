import 'package:flutter/material.dart';
import 'dart:math' as Math;
import '../../model/database_model.dart';
import '../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeList extends StatefulWidget {
  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  late int _selectedWalletIndex;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nome Wallet: ${selectedWallet.name}"),
                        Text("Bilancio: ${selectedWallet.balance}"),
                      ],
                    ),
                    FutureBuilder<List<Transaction>>(
                      future: DatabaseHelper()
                          .getTransactionsForWallet(selectedWallet.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<Transaction> transactions = snapshot.data!;

                          Map<String, double> categoryAmounts =
                              _calculateCategoryAmounts(transactions);
                          return GestureDetector(
                            onTapUp: (details) {
                              _handlePieChartTap(details, categoryAmounts);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 35.0), // Add padding here
                              child: Container(
                                width: 150,
                                height: 150,
                                child: PieChart(
                                  PieChartData(
                                    sections: _createPieChartSections(
                                        categoryAmounts),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 30,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
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
                            _selectedCategory =
                                null; // Reset selected category when changing wallet
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
                        future: DatabaseHelper()
                            .getTransactionsForWallet(selectedWallet.id!),
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
                                          "Data: $formattedDate, Valore: ${transaction.value}"),
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

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String _formatDateTime(DateTime dateTime) {
    final formattedDate =
        "${dateTime.year}/${_twoDigits(dateTime.month)}/${_twoDigits(dateTime.day)}";
    final formattedTime =
        "${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}";
    return "$formattedDate $formattedTime";
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
        color: fixedColors[index % fixedColors.length],
        value: amount,
        title: '${(amount).toStringAsFixed(2)}€',
        radius: isSelected ? 60 : 50, // Highlight selected category
        titleStyle: TextStyle(
          fontSize: isSelected ? 18 : 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
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
        // If the tapped category is already selected, deselect it
        _selectedCategory = null;
      } else {
        // Otherwise, select the tapped category
        _selectedCategory = tappedCategory;
      }
    });
  }

  double _getAngle(Offset position) {
    final centerX = 75.0; // Assuming the center of the PieChart
    final centerY = 75.0; // Assuming the center of the PieChart
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
    return -1; // Default case
  }

  double _getTotalAmount(Map<String, double> categoryAmounts) {
    double total = 0;
    categoryAmounts.values.forEach((amount) {
      total += amount;
    });
    return total;
  }

  void _navigateToTransactionDetail(
      BuildContext context, Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(transaction: transaction),
      ),
    );
  }
}

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  TransactionDetailPage({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio Transazione'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nome Transazione: ${transaction.name}'),
            Text('Valore: ${transaction.value}'),
            Text('Categoria: ${transaction.categoryId}'),
            ElevatedButton(
              onPressed: () {
                _editTransaction(context);
              },
              child: Text('Modifica Transazione'),
            ),
            IconButton(
              onPressed: () {
                _deleteTransaction(context);
              },
              icon: Icon(Icons.delete), // Icona del cestino
              tooltip: 'Elimina Transazione', // Testo informativo
            ),
          ],
        ),
      ),
    );
  }

  void _editTransaction(BuildContext context) {
    // Implement editing logic here
  }

  void _deleteTransaction(BuildContext context) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Elimina transazione'),
        content: Text('Sei sicuro di voler eliminare questa transazione?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false when canceled
            },
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true when confirmed
            },
            child: Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed) {
      // Call deleteTransaction method from WalletProvider
      Provider.of<WalletProvider>(context, listen: false)
          .deleteTransaction(transaction.id!);
      Navigator.of(context).pop(); // Close detail page after deletion
    }
  }
}
