import 'package:flutter/material.dart';
import '../model/database_model.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';


class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  TransactionDetailPage({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio Transazione'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nome Transazione: ${transaction.name}'),
            Text('Valore: ${transaction.value}'),
            Text('Categoria: ${transaction.categoryId}'),
            ElevatedButton(
              onPressed: () {
                _editTransaction(context);
              },
              child: Text('Modifica Transazione'),
            ),
            IconButton(
              onPressed: () {
                _deleteTransaction(context);
              },
              icon: Icon(Icons.delete), // Icona del cestino
              tooltip: 'Elimina Transazione', // Testo informativo
            ),
          ],
        ),
      ),
    );
  }

  void _editTransaction(BuildContext context) {
    // Implement editing logic here
  }

  void _deleteTransaction(BuildContext context) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Elimina transazione'),
        content: Text('Sei sicuro di voler eliminare questa transazione?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false when canceled
            },
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true when confirmed
            },
            child: Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed) {
      // Call deleteTransaction method from WalletProvider
      Provider.of<WalletProvider>(context, listen: false)
          .deleteTransaction(transaction.id!);
      Navigator.of(context).pop(); // Close detail page after deletion
    }
  }
}
