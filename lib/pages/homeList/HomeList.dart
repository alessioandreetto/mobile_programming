import 'package:flutter/material.dart';
import '../../model/database_model.dart';
import '../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';

class HomeList extends StatefulWidget {
  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  late int _selectedWalletIndex; // Indice del wallet selezionato, inizialmente impostato sul primo

  @override
  void initState() {
    super.initState();
    _selectedWalletIndex = 0; // Imposta il primo wallet come selezionato all'inizio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome User'),
        elevation: 0, // Rimuove l'ombra sotto l'AppBar
        backgroundColor: Colors.transparent, // Imposta il colore dell'AppBar
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           Consumer<WalletProvider>(
            builder: (context, walletProvider, _) {
              Wallet selectedWallet = walletProvider.wallets[_selectedWalletIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nome: ${selectedWallet.name}"),
                  Text("Bilancio: ${selectedWallet.balance}"),
                ],
              );
            },
          ),
          Container(
            height: 50, // Imposta l'altezza della lista a 50px
            child: Consumer<WalletProvider>(
              builder: (context, walletProvider, _) {
                List<Wallet> wallets = walletProvider.wallets;
                return ListView.builder(
                  scrollDirection: Axis.horizontal, // Imposta la direzione dello scorrimento orizzontale
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedWalletIndex = index; // Imposta l'indice del wallet selezionato
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return _selectedWalletIndex == index ? Colors.blue : Colors.transparent; // Imposta il colore del pulsante in base allo stato
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
         
        ],
      ),
    );
  }
}
