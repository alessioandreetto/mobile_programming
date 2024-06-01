import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  bool _swipedLeft = true;

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
    int walletCount =
        Provider.of<WalletProvider>(context, listen: false).wallets.length;

    if (walletCount == 0) return;

    if (details.primaryVelocity! < 0) {
      // Swipe a sinistra
      if (_selectedWalletIndex < walletCount - 1) {
        setState(() {
          _selectedWalletIndex++;
          _selectedCategory = null;
          _swipedLeft = true;
        });
      }
    } else if (details.primaryVelocity! > 0) {
      // Swipe a destra
      if (_selectedWalletIndex > 0) {
        setState(() {
          _selectedWalletIndex--;
          _selectedCategory = null;
          _swipedLeft = false;
        });
      }
    }
  }

  void _handleButtonPress(int index) {
    setState(() {
      if (index > _selectedWalletIndex) {
        _swipedLeft = true;
      } else {
        _swipedLeft = false;
      }
      _selectedWalletIndex = index;
      _selectedCategory = null;

      // Notifica al provider l'indice del wallet selezionato
      Provider.of<WalletProvider>(context, listen: false)
          .updateSelectedWalletIndex(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<WalletProvider>(
          builder: (context, walletProvider, _) {
            String userName = walletProvider.name;
            return Text('Benvenuto $userName!');
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          if (walletProvider.wallets.isEmpty) {
            return Center(child: Text('Nessun portafoglio disponibile'));
          }
          Wallet selectedWallet = walletProvider.wallets[_selectedWalletIndex];
          String valuta = walletProvider.valuta;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onHorizontalDragEnd: _handleSwipe,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    final inAnimation = Tween<Offset>(
                      begin: _swipedLeft ? Offset(1.0, 0.0) : Offset(-1.0, 0.0),
                      end: Offset(0.0, 0.0),
                    ).animate(animation);

                    final outAnimation = Tween<Offset>(
                      begin: _swipedLeft ? Offset(-1.0, 0.0) : Offset(1.0, 0.0),
                      end: Offset(0.0, 0.0),
                    ).animate(animation);

                    if (child.key == ValueKey<int>(_selectedWalletIndex)) {
                      return SlideTransition(
                        position: inAnimation,
                        child: child,
                      );
                    } else {
                      return SlideTransition(
                        position: outAnimation,
                        child: child,
                      );
                    }
                  },
                  child: Padding(
                    key: ValueKey<int>(_selectedWalletIndex),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nome Wallet: ${selectedWallet.name}"),
                            Text(
                                'Bilancio : ${selectedWallet.balance} $valuta'),
                            if (_selectedCategory != null)
                              Text(
                                  "$nomeCategoria :  $valoreCategoria $valuta"),
                          ],
                        ),
                        FutureBuilder<List<Transaction>>(
                          future: _fetchTransactions(selectedWallet.id!),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Errore: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Container(
                                width: 150,
                                height: 150,
                              );
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
                ),
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              Expanded(
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
                        future: _fetchTransactions(selectedWallet.id!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Errore: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Text('Nessuna transazione trovata'),
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

                                return Slidable(
                                  key: ValueKey(index),
                                  startActionPane: ActionPane(
                                    extentRatio: 0.25,
                                    motion: ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        borderRadius: BorderRadius.circular(10),
                                        padding: EdgeInsets.all(10),
                                        onPressed: (context) {
                                          _deleteTransaction(
                                              transaction, walletProvider);
                                        },
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
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
              ),
            ],
          );
        },
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
        nomeCategoria = categories[int.parse(tappedCategory)].name;
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
    double total = 0.0;
    categoryAmounts.forEach((_, amount) {
      total += amount;
    });
    return total;
  }

  void _deleteTransaction(
      Transaction transaction, WalletProvider walletProvider) async {
    // Recupera il valore della transazione eliminata
    double deletedTransactionValue = transaction.value ?? 0.0;

    // Elimina la transazione dal database
    await DatabaseHelper().deleteTransaction(transaction.id!);

    // Aggiorna il bilancio del wallet corrispondente
    Wallet selectedWallet = walletProvider.wallets[_selectedWalletIndex];
    selectedWallet.balance = selectedWallet.balance! - deletedTransactionValue;

    // Aggiorna il bilancio del wallet nel database
    await DatabaseHelper().updateWallet(selectedWallet);

    // Aggiorna i wallet nel WalletProvider
    walletProvider.refreshWallets();
  }

  void _navigateToTransactionDetail(
      BuildContext context, Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewTransactionPage(transaction: transaction)),
    );
  }
}
