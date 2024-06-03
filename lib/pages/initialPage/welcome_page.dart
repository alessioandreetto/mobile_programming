import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Benvenuto! Inizia il tuo viaggio finanziario.',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Inserisci il tuo nome per iniziare',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          // Ottieni un'istanza di WalletProvider e aggiorna il nome dell'account
                          Provider.of<WalletProvider>(context, listen: false)
                              .updateAccountName(value);
                        },
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Con questa app semplice e intuitiva, '
                        'potrai tenere traccia delle tue spese quotidiane '
                        'e pianificare un futuro finanziario migliore. '
                        'Inizia ad esplorare il mondo delle tue finanze oggi stesso!',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
