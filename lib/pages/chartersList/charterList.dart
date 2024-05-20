import 'package:flutter/material.dart';
import '../../model/database_model.dart';
import '../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';

class CharterList extends StatelessWidget {
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
                      child: SizedBox(
                        height: 30, // Imposta l'altezza del pulsante a 30px
                        child: ElevatedButton(
                          onPressed: () {
                            // Aggiungi qui l'azione quando il pulsante viene premuto
                          },
                          child: Text(wallets[index].name!),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
