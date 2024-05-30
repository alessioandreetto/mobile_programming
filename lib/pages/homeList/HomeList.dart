import 'package:flutter/material.dart';
import 'dart:math' as Math;
import '../../model/database_model.dart';
import '../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../new_operation.dart';

class HomeList extends StatefulWidget {
  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  late int _selectedWalletIndex;
  double valoreCategoria = 0;
  String nomeCategoria = '';
  String? _selectedCategory;
  bool _showExpenses = true;

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
    _selectedWalletIndex = 0;
    _selectedCategory = null;
    Provider.of<WalletProvider>(context, listen: false).loadAccountName();
    Provider.of<WalletProvider>(context, listen: false).loadValuta();
  }

void _handleSwipe(DragEndDetails details) {
  final walletProvider = Provider.of<WalletProvider>(context, listen: false);
  final wallets = walletProvider.wallets;
  final currentWalletId = wallets[_selectedWalletIndex].id;
  final nextWalletIndex = details.primaryVelocity! < 0
      ? (_selectedWalletIndex + 1) % wallets.length
      : (_selectedWalletIndex - 1 + wallets.length) % wallets.length;
  final nextWalletId = wallets[nextWalletIndex].id;
  
  if (currentWalletId != null && nextWalletId != null) {
    setState(() {
      _selectedWalletIndex = nextWalletIndex;
      _selectedCategory = null;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<WalletProvider>(
          builder: (context, walletProvider, _) {
            String userName = walletProvider.name;
            return Text('Welcome $userName!');
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<WalletProvider>(
            builder: (context, walletProvider, _) {
              final selectedWallet = walletProvider.wallets[_selectedWalletIndex];
              final valuta = walletProvider.valuta;
              final wallets = walletProvider.wallets;
              return GestureDetector(
                onHorizontalDragEnd: wallets.length > 1 ? _handleSwipe : null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nome Wallet: ${selectedWallet.name}"),
                          Text('Bilancio : ${selectedWallet.balance} $valuta'),
                          if (_selectedCategory != null)
                            Text("$nomeCategoria :  $valoreCategoria $valuta"),
                        ],
                      ),
                      FutureBuilder<List<Transaction>>(
                        future: _fetchTransactions(selectedWallet.id!),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                  ),
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
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(color: Colors.black),
                            ),
                          ),
                          foregroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return _selectedWalletIndex == index
                                  ? Colors.white
                                  : Colors.black;
                            },
                          ),
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
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
                final selectedWallet = walletProvider.wallets[_selectedWalletIndex];
                return GestureDetector(
                  onHorizontalDragEnd: walletProvider.wallets.length > 1 ? _handleSwipe : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Transazioni per ${selectedWallet.name}:"),
                            DropdownButton<bool>(
                              value: _showExpenses,
                              onChanged: (value) {
                                setState(() {
                                  _showExpenses = value!;
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
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: FutureBuilder<List<Transaction>>(
                          future
: _fetchTransactions(selectedWallet.id!),
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
                                  final date =
                                      DateTime.parse(transaction.date!);
                                  final formattedDate = _formatDateTime(date);
                                  return Dismissible(
                                    key: Key(transaction.id.toString()),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      _deleteTransaction(
                                          transaction, walletProvider);
                                    },
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Icon(Icons.delete,
                                          color: Colors.white),
                                    ),
                                    child: GestureDetector(
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        child: ListTile(
                                          title: Text(transaction.name ?? ''),
                                          subtitle: Text(
                                              "Data: $formattedDate, Valore: ${transaction.value} ${walletProvider.valuta}"),
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
                  ),
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
    if (_showExpenses) {
      transactions =
          transactions.where((transaction) => transaction.value! < 0).toList();
    } else if (!_showExpenses) {
      transactions =
          transactions.where((transaction) => transaction.value! > 0).toList();
    }
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
      if (amount > 0) {
        bool isSelected = _selectedCategory == category;
        sections.add(PieChartSectionData(
          color: fixedColors[index % fixedColors.length], // Utilizza colori fissi ciclicamente
          value: amount,
          title: '',
          radius: isSelected ? 100 : 90,
        ));
        index++;
      }
    });

    return sections;
  }

  void _handlePieChartTap(
      TapUpDetails details, Map<String, double> categoryAmounts) {
    final touchPos = details.localPosition;
    final touchAngle = _getAngle(touchPos);
    final categoryIndex = _getTouchedCategoryIndex(touchAngle, categoryAmounts);

    setState(() {
      if (categoryIndex != -1) {
        String tappedCategory = categoryAmounts.keys.elementAt(categoryIndex);
        if (_selectedCategory == tappedCategory) {
          _selectedCategory = null;
        } else {
          _selectedCategory = tappedCategory;
          nomeCategoria = categories[int.parse(tappedCategory)].name;
          valoreCategoria = categoryAmounts[tappedCategory]!;
        }
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
      Transaction transaction, WalletProvider walletProvider) {
    walletProvider
        .deleteTransaction(transaction.id!); // Assuming id is not nullable
    walletProvider
        .reloadWalletBalance(); // Aggiorna il saldo del wallet dopo l'eliminazione della transazione
  }
}
