import 'package:flutter/material.dart';
import '../../model/database_model.dart';
import '../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';

class HomeList extends StatefulWidget {
  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  late int
      _selectedWalletIndex; // Indice del wallet selezionato, inizialmente impostato sul primo

  @override
  void initState() {
    super.initState();
    _selectedWalletIndex =
        0; // Imposta il primo wallet come selezionato all'inizio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome User'),
        elevation: 0, // Rimuove l'ombra sotto l'AppBar
        backgroundColor: Colors.transparent, // Imposta il colore dell'AppBar
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sezione per il nome del wallet e il bilancio
          Consumer<WalletProvider>(
            builder: (context, walletProvider, _) {
              Wallet selectedWallet =
                  walletProvider.wallets[_selectedWalletIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nome Wallet: ${selectedWallet.name}"),
                  Text("Bilancio: ${selectedWallet.balance}"),
                ],
              );
            },
          ),
          SizedBox(height: 20),
          // Lista orizzontale di bottoni per i wallet
          Container(
            height: 50, // Imposta l'altezza della lista a 50px
            child: Consumer<WalletProvider>(
              builder: (context, walletProvider, _) {
                List<Wallet> wallets = walletProvider.wallets;
                return ListView.builder(
                  scrollDirection: Axis
                      .horizontal, // Imposta la direzione dello scorrimento orizzontale
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedWalletIndex =
                                index; // Imposta l'indice del wallet selezionato
                          });
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          shape : MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(
                                color:  Colors.black
                                   
                              ),
                            ),
                          ),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return _selectedWalletIndex == index
                                  ? Colors.white
                                  : Colors
                                      .black; // Imposta il colore del testo in base allo stato
                            },
                          ),
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return _selectedWalletIndex == index
                                  ? Colors.black
                                  : Colors
                                      .white; // Imposta il colore del pulsante in base allo stato
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
          // Lista verticale delle transazioni
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
                              child:
                                  CircularProgressIndicator(), // Visualizza un indicatore di caricamento durante il recupero dei dati
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
}
