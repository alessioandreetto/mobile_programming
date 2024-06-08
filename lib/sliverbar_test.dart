import 'package:flutter/material.dart';
import '../providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import '../model/database_model.dart';
import 'dart:math' as Math;
import 'package:intl/intl.dart';
import '../pages/new_operation.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => WalletProvider(),
        child: WalletSliverScreen(),
      ),
    );
  }
}

class WalletSliverScreen extends StatefulWidget {
  @override
  _WalletSliverScreenState createState() => _WalletSliverScreenState();
}

class _WalletSliverScreenState extends State<WalletSliverScreen> {
  late List<Transaction> transactions = [];
  late int _selectedWalletIndex = 0;
  bool _showExpenses = true;
  double valoreCategoria = 0;
  String nomeCategoria = '';
  String? _selectedCategory;

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
    _loadTransactions(_selectedWalletIndex);
  }

  Future<List<Transaction>> _loadTransactions(int walletIndex) async {
    try {
      List<Transaction> loadedTransactions = await DatabaseHelper()
          .getTransactionsForWallet(walletIndex + 1); // Aggiungi 1 perché gli indici iniziano da 0

      if (_showExpenses) {
        loadedTransactions = loadedTransactions
            .where((transaction) => transaction.value! < 0)
            .toList();
      } else {
        loadedTransactions = loadedTransactions
            .where((transaction) => transaction.value! >= 0)
            .toList();
      }

      loadedTransactions.sort((a, b) => b.date!.compareTo(a.date!));

      setState(() {
        transactions = loadedTransactions;
      });

      return loadedTransactions;
    } catch (e) {
      print('Errore durante il caricamento delle transazioni: $e');
      return [];
    }
  }

  void _navigateToTransactionDetail(BuildContext context, Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewTransactionPage(transaction: transaction)),
    );
  }

  List<PieChartSectionData> _createPieChartSections(Map<String, double> categoryAmounts) {
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

  void _handlePieChartTap(TapUpDetails details, Map<String, double> categoryAmounts) {
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

  int _getTouchedCategoryIndex(double angle, Map<String, double> categoryAmounts) {
    final totalAmount = getTotalAmount(categoryAmounts);
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

  double getTotalAmount(Map<String, double> categoryAmounts) {
    double total = 0.0;
    categoryAmounts.forEach((_, amount) {
      total += amount;
    });
    return total;
  }

  Map<String, double> _calculateCategoryAmounts(List<Transaction> transactions) {
    Map<String, double> categoryAmounts = {};
    transactions.forEach((transaction) {
      final categoryId = transaction.categoryId.toString();
      final value = transaction.value ?? 0.0;
      if (categoryAmounts.containsKey(categoryId)) {
        categoryAmounts[categoryId] = (categoryAmounts[categoryId] ?? 0) + value;
      } else {
        categoryAmounts[categoryId] = value;
      }
    });

    return categoryAmounts;
  }

  @override
  Widget build(BuildContext context) {
    var walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            surfaceTintColor: Colors.transparent,
            pinned: true,
            snap: true,
            title: Consumer<WalletProvider>(
              builder: (context, walletProvider, _) {
                String userName = walletProvider.name;
                return Text('Benvenuto $userName!');
              },
            ),
            floating: true,
            expandedHeight: 300.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                child:  Container(
                      height: 300,
                      width: 300,
                      color: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 130.0),
                        child: FutureBuilder<List<Transaction>>(
                          future: _loadTransactions(_selectedWalletIndex),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Errore: ${snapshot.error}'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Container(
                                width: 150,
                                height: 150,
                              );
                            } else {
                              List<Transaction> transactions = snapshot.data!;
                              Map<String, double> categoryAmounts = _calculateCategoryAmounts(transactions);
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
                                        sections: _createPieChartSections(categoryAmounts),
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
                      ),
                    ),
                  
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverPersistentHeaderDelegate(
              minHeight: 170.0,
              maxHeight: 170.0,
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Nome Wallet: ${walletProvider.wallets[_selectedWalletIndex].name}", style: TextStyle(fontSize: 20)),
                          Text(
                              'Bilancio: ${walletProvider.wallets[_selectedWalletIndex].balance} ${walletProvider.valuta}', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: walletProvider.wallets.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedWalletIndex = index;
                                });
                                _loadTransactions(index);
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
                              child: Text(walletProvider.wallets[index].name!),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Transazioni per ${walletProvider.wallets[_selectedWalletIndex].name}:",
                            style: TextStyle(fontSize: 16),
                          ),
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
                final date = DateTime.parse(transaction.date!);
                final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                return GestureDetector(
                  onTap: () {
                    _navigateToTransactionDetail(context, transaction);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 70.0,
                      child: ListTile(
                        title: Text(transaction.name ?? ''),
                        subtitle: Text(
                          "Data: $formattedDate, Valore: ${transaction.value} ${walletProvider.valuta}",
                        ),
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xffb3b3b3),
                        ),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                );
              },
              childCount: transactions.length,
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverPersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
