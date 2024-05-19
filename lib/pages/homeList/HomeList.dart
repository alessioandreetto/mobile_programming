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

  @override
  void initState() {
    super.initState();
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
                          return Container(
                            width: 150,
                            height: 150,
                            child: PieChart(
                              PieChartData(
                                sections:
                                    _createPieChartSections(categoryAmounts),
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
                          });
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
                            return ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                return Container(
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
                                    title: Text(transactions.reversed
                                            .toList()[index]
                                            .name ??
                                        ''),
                                    subtitle: Text(
                                        "Data: ${transactions.reversed.toList()[index].date}, Valore: ${transactions.reversed.toList()[index].value}"),
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

Map<String, double> _calculateCategoryAmounts(
  List<Transaction> transactions,
) {
  Map<String, double> categoryAmounts = {};

  transactions.forEach((transaction) {
    final categoryId = transaction.categoryId.toString(); // Convertiamo l'ID della categoria in una stringa
    final value = transaction.value ?? 0.0; // Utilizziamo 0.0 come valore predefinito se value è nullo
    if (categoryAmounts.containsKey(categoryId)) {
      categoryAmounts[categoryId] = (categoryAmounts[categoryId] ?? 0) + value;
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
  ];

  List<PieChartSectionData> sections = [];
  int index = 0;

  categoryAmounts.forEach((category, amount) {
    sections.add(PieChartSectionData(
      color: fixedColors[index % fixedColors.length],
      value: amount,
      title: 'Category ${index+1}: ${(amount ).toStringAsFixed(2)}€',
    ));
    index++;
  });

  return sections;
}


  double _getTotalAmount(Map<String, double> categoryAmounts) {
    double total = 0;
    categoryAmounts.values.forEach((amount) {
      total += amount;
    });
    return total;
  }

}
