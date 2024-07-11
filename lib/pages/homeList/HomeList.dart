import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import '../../model/database_model.dart';
import 'dart:math' as Math;
import 'package:intl/intl.dart';
import '../new_operation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => WalletProvider(),
        child: HomeList(),
      ),
    );
  }
}

class HomeList extends StatefulWidget {
  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  late List<Transaction> transactions = [];
  late int _selectedWalletId;
  late String _selectedValuta;
  bool _showExpenses = WalletProvider().getTipologiaMovimento();
  double valoreCategoria = 0;
  String nomeCategoria = '';
  String? _selectedCategory;
  PageController _pageController = PageController();

  List<Category> categories = [
    Category(id: 1, name: 'Auto'),
    Category(id: 2, name: 'Banca'),
    Category(id: 3, name: 'Casa'),
    Category(id: 4, name: 'Intrattenimento'),
    Category(id: 5, name: 'Shopping'),
    Category(id: 6, name: 'Viaggio'),
    Category(id: 7, name: 'Varie'),
  ];

  Map<int, Color> categoryColors = {
    0: Colors.red,
    1: Colors.blue,
    2: Colors.green,
    3: Colors.orange,
    4: Colors.purple,
    5: Colors.yellow,
    6: Colors.brown,
  };

  Map<int, IconData> categoryIcons = {
    0: Icons.directions_car,
    1: Icons.account_balance,
    2: Icons.home,
    3: Icons.movie,
    4: Icons.shopping_cart,
    5: Icons.airplanemode_active,
    6: Icons.category,
  };

  @override
  void initState() {
    super.initState();
    _selectedWalletId = 0;
    _initSelectedWallet();
    Provider.of<WalletProvider>(context, listen: false)
        .addListener(_onWalletsChanged);
  }

  @override
  void dispose() {
    Provider.of<WalletProvider>(context, listen: false)
        .removeListener(_onWalletsChanged);
    super.dispose();
  }

  void _initSelectedWallet() {
    var walletProvider = Provider.of<WalletProvider>(context, listen: false);

    _showExpenses = walletProvider.getTipologiaMovimento();
    if (walletProvider.wallets.isNotEmpty) {
      final selectedWalletIndex = walletProvider.getSelectedWalletIndex();
      final selectedWallet = walletProvider.wallets[selectedWalletIndex];
      setState(() {
        _selectedValuta = walletProvider.valuta;
      });
      _loadTransactions(selectedWalletIndex + 1);
    } else {
      setState(() {
        _selectedWalletId = 0;
      });
    }
    walletProvider.loadAccountName();
  }

  void _onWalletsChanged() {
    var walletProvider = Provider.of<WalletProvider>(context, listen: false);
    if (!walletProvider.wallets
        .any((wallet) => wallet.id == _selectedWalletId)) {
      setState(() {
        _selectedWalletId = walletProvider.wallets.isNotEmpty
            ? walletProvider.wallets.first.id!
            : 0;
      });
      _loadTransactions(_selectedWalletId);
    }
  }

  void _handleSwipe(int index) {
    final walletId =
        Provider.of<WalletProvider>(context, listen: false).wallets[index].id!;

    _loadTransactions(walletId);
    Provider.of<WalletProvider>(context, listen: false)
        .updateSelectedWalletIndex(index);
  }

  Future<List<Transaction>> _loadTransactions(int walletId) async {
    try {
      List<Transaction> loadedTransactions =
          await DatabaseHelper().getTransactionsForWallet(walletId);

      if (Provider.of<WalletProvider>(context, listen: false)
          .getTipologiaMovimento()) {
        loadedTransactions = loadedTransactions
            .where((transaction) => transaction.value! < 0)
            .toList();
      } else {
        loadedTransactions = loadedTransactions
            .where((transaction) => transaction.value! >= 0)
            .toList();
      }

      WalletProvider walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      int selectedCategoryIndex = walletProvider.getSelectedCategoryIndex();

      if (selectedCategoryIndex != -1) {
        print(selectedCategoryIndex);
        transactions = loadedTransactions
            .where((transaction) =>
                transaction.categoryId == selectedCategoryIndex)
            .toList();
        transactions.sort((a, b) => b.date!.compareTo(a.date!));
      }

      loadedTransactions.sort((a, b) => b.date!.compareTo(a.date!));

      setState(() {
        if (selectedCategoryIndex == -1) {
          transactions = loadedTransactions;
        }
      });

      return loadedTransactions;
    } catch (e) {
      print('Errore durante il caricamento delle transazioni: $e');
      return [];
    }
  }

  void _navigateToTransactionDetail(
      BuildContext context, Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewTransactionPage(transaction: transaction)),
    );
  }

  List<PieChartSectionData> _createPieChartSections(
      Map<String, double> categoryAmounts) {
    Map<int, Color> categoryColors = {
      0: Colors.red,
      1: Colors.blue,
      2: Colors.green,
      3: Colors.orange,
      4: Colors.purple,
      5: Colors.yellow,
      6: Colors.brown,
    };

    List<PieChartSectionData> sections = [];
    int index = 0;

    categoryAmounts.forEach((category, amount) {
      bool isSelected = _selectedCategory == category;
      sections.add(PieChartSectionData(
        color: categoryColors[int.parse(category)],
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
        nomeCategoria = '';
        valoreCategoria = 0;
      } else {
        _selectedCategory = tappedCategory;
        nomeCategoria = categories[int.parse(tappedCategory)].name;
        valoreCategoria = categoryAmounts[tappedCategory]!;
      }
    });

    WalletProvider walletProvider =
        Provider.of<WalletProvider>(context, listen: false);
    walletProvider.updateSelectedCategoryIndex(
        _selectedCategory != null ? int.parse(_selectedCategory!) : -1);
  }

  double _getAngle(Offset position) {
    final centerX = 100.0;
    final centerY = 100.0;
    final dx = position.dx - centerX;
    final dy = position.dy - centerY;
    final angle = (Math.atan2(dy, dx) * 180 / Math.pi + 360) % 360;
    return angle;
  }

  int _getTouchedCategoryIndex(
      double angle, Map<String, double> categoryAmounts) {
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

  void _deleteTransaction(
      Transaction transaction, WalletProvider walletProvider) async {
    double deletedTransactionValue = transaction.value ?? 0.0;

    await DatabaseHelper().deleteTransaction(transaction.id!);

    Wallet selectedWallet = walletProvider.wallets
        .firstWhere((wallet) => wallet.id == _selectedWalletId);
    selectedWallet.balance = selectedWallet.balance! - deletedTransactionValue;

    await DatabaseHelper().updateWallet(selectedWallet);

    walletProvider.refreshWallets();
    walletProvider.notifyListeners();
  }

  Map<String, double> _calculateCategoryAmounts(
      List<Transaction> transactions) {
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

  void _handleButtonPress(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  String formatNumber(double number) {
    String sign = number < 0 ? '-' : '';
    number = number.abs();

    if (number >= 1000000000) {
      int intPart = (number / 1000000000).floor();
      int decimalPart = ((number % 1000000000) / 100000000).floor();
      return sign + intPart.toString() + '.' + decimalPart.toString() + 'B';
    } else if (number >= 1000000) {
      int intPart = (number / 1000000).floor();
      int decimalPart = ((number % 1000000) / 100000).floor();
      return sign + intPart.toString() + '.' + decimalPart.toString() + 'M';
    } else if (number >= 1000) {
      int intPart = (number / 1000).floor();
      int decimalPart = ((number % 1000) / 100).floor();
      return sign + intPart.toString() + '.' + decimalPart.toString() + 'k';
    } else {
      return sign + number.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    var walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              expandedHeight: transactions.isEmpty ? 0.0 : 300.0,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              snap: true,
              title: RichText(
                text: TextSpan(
                  text: 'Ciao, ',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 25.0,
                      color: (Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white)),
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${walletProvider.name.length > 15 ? walletProvider.name.substring(0, 15) + '...' : walletProvider.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '!',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                  background: PageView.builder(
                controller: _pageController,
                itemCount: walletProvider.wallets.length,
                onPageChanged: _handleSwipe,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    child: Center(
                      child: FutureBuilder<List<Transaction>>(
                        future: _loadTransactions(
                            walletProvider.selectedWalletIndex + 1),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Errore: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Container();
                          } else {
                            final transactions = snapshot.data!;
                            final categoryAmounts =
                                _calculateCategoryAmounts(transactions);

                            return GestureDetector(
                              onTapUp: (details) {
                                _handlePieChartTap(details, categoryAmounts);
                              },
                              child: ClipOval(
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.transparent,
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
                    ),
                  );
                },
              )),
            ),
          ),
        ];
      },
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverPersistentHeaderDelegate(
                minHeight: 230.0,
                maxHeight: 230.0,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 8.0, top: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (walletProvider.wallets.isNotEmpty)
                              RichText(
                                text: TextSpan(
                                  text: 'Nome Portafoglio: ',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12.0,
                                      color: (Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white)),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          '${walletProvider.wallets.firstWhere((wallet) => wallet.id == walletProvider.selectedWalletIndex + 1, orElse: () => Wallet(id: 0, name: 'N/A', balance: 0)).name!.length > 12 ? walletProvider.wallets.firstWhere((wallet) => wallet.id == walletProvider.selectedWalletIndex + 1, orElse: () => Wallet(id: 0, name: 'N/A', balance: 0)).name!.substring(0, 12) + '...' : walletProvider.wallets.firstWhere((wallet) => wallet.id == walletProvider.selectedWalletIndex + 1, orElse: () => Wallet(id: 0, name: 'N/A', balance: 0)).name}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                    ),
                                  ],
                                ),
                              ),
                            if (walletProvider.wallets.isNotEmpty)
                              RichText(
                                text: TextSpan(
                                  text: 'Bilancio: ',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12.0,
                                      color: (Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white)),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          '${formatNumber(walletProvider.wallets.firstWhere((wallet) => wallet.id == walletProvider.selectedWalletIndex + 1, orElse: () => Wallet(id: 0, name: 'N/A', balance: 0)).balance ?? 0.0)} ${walletProvider.valuta}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (nomeCategoria.isNotEmpty) ...[
                              RichText(
                                text: TextSpan(
                                  text: '$nomeCategoria: ',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12.0,
                                      color: (Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white)),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          '${formatNumber(valoreCategoria)} ${walletProvider.valuta}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                          color: valoreCategoria < 0
                                              ? Colors.red
                                              : Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (nomeCategoria.isEmpty) ...[
                              Text(
                                ' ',
                                style: TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
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

                                    walletProvider
                                        .updateSelectedWalletIndex(index);
                                    _loadTransactions(
                                        walletProvider.selectedWalletIndex + 1);
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
                                  child: Text(walletProvider
                                              .wallets[index].name!.length >
                                          9
                                      ? '${walletProvider.wallets[index].name!.substring(0, 9)}...'
                                      : walletProvider.wallets[index].name!),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (walletProvider.wallets.isNotEmpty)
                              Text(
                                "Transazioni per ${walletProvider.wallets.firstWhere((wallet) => wallet.id == walletProvider.selectedWalletIndex + 1, orElse: () => Wallet(id: 0, name: 'N/A', balance: 0)).name!.length > 9 ? '${walletProvider.wallets.firstWhere((wallet) => wallet.id == walletProvider.selectedWalletIndex + 1, orElse: () => Wallet(id: 0, name: 'N/A', balance: 0)).name!.substring(0, 9)}...' : walletProvider.wallets.firstWhere((wallet) => wallet.id == walletProvider.selectedWalletIndex + 1, orElse: () => Wallet(id: 0, name: 'N/A', balance: 0)).name}:",
                                style: TextStyle(fontSize: 14),
                              ),
                            DropdownButton<bool>(
                              value: walletProvider.getTipologiaMovimento(),
                              onChanged: (value) {
                                setState(() {
                                  _showExpenses = value!;
                                  walletProvider.updateTipologia(_showExpenses);
                                  _loadTransactions(
                                      walletProvider.selectedWalletIndex + 1);
                                });
                              },
                              items: [
                                DropdownMenuItem<bool>(
                                  value: true,
                                  child: Text(
                                    'Mostra Uscite',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                DropdownMenuItem<bool>(
                                  value: false,
                                  child: Text(
                                    'Mostra Entrate',
                                    style: TextStyle(fontSize: 14),
                                  ),
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
                  if (transactions.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Center(
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
                      ),
                    );
                  } else {
                    final Transaction transaction = transactions[index];
                    final date = DateTime.parse(transaction.date!);
                    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                    return Slidable(
                      key: ValueKey(index),
                      startActionPane: ActionPane(
                        extentRatio: 0.25,
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            borderRadius: BorderRadius.circular(10),
                            padding: EdgeInsets.all(5),
                            onPressed: (context) {
                              _deleteTransaction(transaction, walletProvider);
                              setState(() {
                                transactions.removeAt(index);
                              });
                            },
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                            foregroundColor: Colors.red,
                            icon: Icons.delete,
                            label: 'Elimina',
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          _navigateToTransactionDetail(context, transaction);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 3.0, right: 5.0, bottom: 3.0),
                          child: Card(
                            child: Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(8),
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: categoryColors[
                                            transaction.categoryId] ??
                                        Colors.grey,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      categoryIcons[transaction.categoryId] ??
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: transaction.name!.length > 15
                                              ? transaction.name!
                                                      .substring(0, 15) +
                                                  '...'
                                              : transaction.name,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color:
                                                (Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    : Colors.white),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ' - ' +
                                                  categories[int.parse(
                                                          transaction.categoryId
                                                              .toString())]
                                                      .name,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: (Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    : Colors.white),
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(formattedDate,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    : Colors.white,
                                          )),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${formatNumber(transaction.value ?? 0)} ${walletProvider.valuta}",
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
                  }
                },
                childCount: transactions.length == 0 ? 1 : transactions.length,
              ),
            )
          ],
        ),
      ),
    ));
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverPersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
