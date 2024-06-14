import 'package:flutter/material.dart';
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
  bool _showExpenses = true;
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
    // Inizializza lo stato selezionando il primo wallet se presente
    _initSelectedWallet();
    // Ascolta i cambiamenti nel provider dei wallet
    Provider.of<WalletProvider>(context, listen: false)
        .addListener(_onWalletsChanged);
  }

  @override
  void dispose() {
    // Rimuovi il listener quando il widget viene eliminato
    Provider.of<WalletProvider>(context, listen: false)
        .removeListener(_onWalletsChanged);
    super.dispose();
  }

  void _initSelectedWallet() {
    var walletProvider = Provider.of<WalletProvider>(context, listen: false);
    if (walletProvider.wallets.isNotEmpty) {
      final selectedWalletIndex = walletProvider.selectedWalletIndex;
      final selectedWallet = walletProvider.wallets[selectedWalletIndex];
      setState(() {
        _selectedWalletId = selectedWallet.id!;
        _selectedValuta = walletProvider.valuta;
      });
      _loadTransactions(selectedWallet.id!);
    } else {
      setState(() {
        _selectedWalletId = 0;
      });
    }
    walletProvider.loadAccountName();
  }

  void _onWalletsChanged() {
    var walletProvider = Provider.of<WalletProvider>(context, listen: false);
    // Controlla se il wallet attualmente selezionato è stato eliminato
    if (!walletProvider.wallets
        .any((wallet) => wallet.id == _selectedWalletId)) {
      // Se il wallet attualmente selezionato è stato eliminato, seleziona automaticamente il wallet con l'indice più basso
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
    setState(() {
      _selectedWalletId = walletId;
      _selectedCategory = null;
    });
    _loadTransactions(walletId);
    Provider.of<WalletProvider>(context, listen: false)
        .updateSelectedWalletIndex(index);
  }

  Future<List<Transaction>> _loadTransactions(int walletId) async {
    try {
      List<Transaction> loadedTransactions =
          await DatabaseHelper().getTransactionsForWallet(walletId);

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
      0: Colors.red, // Auto
      1: Colors.blue, // Banca
      2: Colors.green, // Casa
      3: Colors.orange, // Intrattenimento
      4: Colors.purple, // Shopping
      5: Colors.yellow, // Viaggio
      6: Colors.brown, // Varie
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
  }

  double _getAngle(Offset position) {
    final centerX = 150.0; // Updated to match the size of the PieChart
    final centerY = 150.0; // Updated to match the size of the PieChart
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
// Recupera il valore della transazione eliminata
    double deletedTransactionValue = transaction.value ?? 0.0;
// Elimina la transazione dal database
    await DatabaseHelper().deleteTransaction(transaction.id!);

// Aggiorna il bilancio del wallet corrispondente
    Wallet selectedWallet = walletProvider.wallets
        .firstWhere((wallet) => wallet.id == _selectedWalletId);
    selectedWallet.balance = selectedWallet.balance! - deletedTransactionValue;

// Aggiorna il bilancio del wallet nel database
    await DatabaseHelper().updateWallet(selectedWallet);

// Aggiorna i wallet nel WalletProvider
    walletProvider.refreshWallets();
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
              title: Text('Benvenuto ${walletProvider.name} !'),
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
                      // Centrato il grafico a torta
                      child: FutureBuilder<List<Transaction>>(
                        future: _loadTransactions(_selectedWalletId),
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
                              child: Container(
                                width:
                                    300, // Increased size to match the center position
                                height:
                                    300, // Increased size to match the center position
                                child: PieChart(
                                  PieChartData(
                                    sections: _createPieChartSections(
                                        categoryAmounts),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 0,
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
                minHeight: 240.0, // Increased to accommodate additional texts
                maxHeight: 240.0, // Increased to accommodate additional texts
                child: Container(
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
                              Text(
                                  "Nome Wallet: ${walletProvider.wallets.firstWhere((wallet) => wallet.id == _selectedWalletId, orElse: () => Wallet(id: 0, name: 'N/A', balance: 0)).name}",
                                  style: TextStyle(fontSize: 20)),
                            if (walletProvider.wallets.isNotEmpty)
                              Text(
                                  'Bilancio: ${walletProvider.wallets.firstWhere((wallet) => wallet.id == _selectedWalletId, orElse: () => Wallet(id: 0, name: 'N/A', balance: 0)).balance} ${walletProvider.valuta}',
                                  style: TextStyle(fontSize: 20)),
                            if (nomeCategoria.isNotEmpty) ...[
                              Text(
                                  '$nomeCategoria : $valoreCategoria ${walletProvider.valuta}',
                                  style: TextStyle(fontSize: 20)),
                            ],
                            if (nomeCategoria.isEmpty) ...[
                              Text(' ', style: TextStyle(fontSize: 20))
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
                                    setState(() {
                                      _selectedWalletId =
                                          walletProvider.wallets[index].id!;
                                    });
                                    _loadTransactions(
                                        walletProvider.wallets[index].id!);
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
                                          return _selectedWalletId ==
                                                  walletProvider
                                                      .wallets[index].id!
                                              ? Colors.white
                                              : Colors.black;
                                        } else {
                                          return _selectedWalletId ==
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
                                          return _selectedWalletId ==
                                                  walletProvider
                                                      .wallets[index].id!
                                              ? Colors.black
                                              : Colors.white;
                                        } else {
                                          return _selectedWalletId ==
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
                                          color: _selectedWalletId ==
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (walletProvider.wallets.isNotEmpty)
                              Text(
                                "Transazioni per ${walletProvider.wallets.firstWhere((wallet) => wallet.id == _selectedWalletId, orElse: () => Wallet(id: 0, name: 'N/A', balance: 0)).name}:",
                                style: TextStyle(fontSize: 16),
                              ),
                            DropdownButton<bool>(
                              value: _showExpenses,
                              onChanged: (value) {
                                setState(() {
                                  _showExpenses = value!;
                                  _loadTransactions(_selectedWalletId);
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
                  if (transactions.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Center(
                        child: Text(
                          'Nessuna transazione',
                          style: TextStyle(fontSize: 18.0),
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
                            padding: EdgeInsets.all(20),
                            onPressed: (context) {
                              _deleteTransaction(transaction, walletProvider);
                              setState(() {
                                transactions.removeAt(index);
                              });
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
                          _navigateToTransactionDetail(context, transaction);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 70.0,
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      categoryColors[transaction.categoryId] ??
                                          Colors.grey,
                                ),
                                child: Icon(
                                  categoryIcons[transaction.categoryId] ??
                                      Icons.category,
                                  color: Colors.white,
                                ),
                              ),
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
                      ),
                    );
                  }
                },
                // Assicura che almeno un elemento venga visualizzato, anche se transactions è vuoto
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
