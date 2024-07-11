import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../model/database_model.dart';
import 'new_wallet.dart';
import '../providers/wallet_provider.dart';
import 'package:provider/provider.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class Note {
  int? id;
  double title;
  String body;

  Note({
    this.id,
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

String formatNumber(double number) {
  String sign = number < 0 ? '-' : '';
  number = number.abs();

  if (number >= 1000000) {
    return sign + (number / 1000000).toStringAsFixed(1) + 'M';
  } else if (number >= 1000) {
    return sign + (number / 1000).toStringAsFixed(1) + 'k';
  } else {
    return sign + number.toStringAsFixed(2);
  }
}

class _WalletPageState extends State<WalletPage> {
  List<Note> data = [];
  Set<int> selectedIndices = Set();

  @override
  void initState() {
    super.initState();
    Provider.of<WalletProvider>(context, listen: false).loadValuta();
    // Non è necessario chiamare _loadNotes() qui, lo chiameremo in didChangeDependencies().
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chiamiamo _loadNotes() qui per essere sicuri che venga chiamato quando il Provider notifica i cambiamenti.
    _loadNotes();
  }

  void _loadNotes() async {
    List<Wallet> wallets =
        await Provider.of<WalletProvider>(context, listen: false).loadWallets();

    setState(() {
      data = wallets
          .map((wallet) => Note(
                id: wallet.id,
                title: wallet.balance!,
                body: wallet.name!,
              ))
          .toList();
    });
  }

  void _saveNotes() async {
    List<Wallet> wallets = data
        .map((note) => Wallet(
              id: note.id,
              name: note.body,
              balance: note.title,
            ))
        .toList();
    for (var wallet in wallets) {
      if (wallet.id == null) {
        await DatabaseHelper().insertWallet(wallet);
      } else {
        await DatabaseHelper().updateWallet(wallet);
      }
    }
  }

  void addOrEditNote({
    required BuildContext context,
    required int index,
    required double title,
    required String body,
  }) async {
    if (index >= 0 && index < data.length) {
      // Update existing wallet
      Wallet existingWallet =
          await DatabaseHelper().getWalletById(data[index].id!);
      Wallet updatedWallet = Wallet(
        id: existingWallet.id,
        name: body,
        balance: title,
      );
      await DatabaseHelper().updateWallet(updatedWallet);
      setState(() {
        data[index] = Note(
          id: existingWallet.id,
          title: title,
          body: body,
        );
      });
      Provider.of<WalletProvider>(context, listen: false).loadWallets();
    } else {
      // Insert new wallet
      Wallet newWallet = Wallet(
        name: body,
        balance: title,
      );
      int id = await DatabaseHelper().insertWallet(newWallet);
      setState(() {
        data.add(Note(
          id: id,
          title: title,
          body: body,
        ));
      });
      Provider.of<WalletProvider>(context, listen: false).loadWallets();
    }
  }

  void deleteNote(int index) async {
    int id = data[index].id!;
    await DatabaseHelper().deleteWallet(id);
    setState(() {
      data.removeAt(index);
    });
    Provider.of<WalletProvider>(context, listen: false).loadWallets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Portafogli',
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          if (selectedIndices.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Implement delete functionality
              },
            ),
        ],
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          String valuta = walletProvider.valuta;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ReorderableGridView.count(
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  crossAxisCount: 2,
                  children: walletProvider.wallets.map((wallet) {
                    final index = walletProvider.wallets.indexOf(wallet);
                    return buildItem(
                        context, index, wallet.balance!, wallet.name!, valuta);
                  }).toList(),
                  onReorder: (oldIndex, newIndex) {
                    // Implement reorder functionality
                  },
                  footer: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddNotePage(
                              onSave: (title, body) {
                                addOrEditNote(
                                  context: context,
                                  index: -1,
                                  title: title,
                                  body: body,
                                );
                                Navigator.pop(context);
                              },
                              walletId:
                                  -1, // Passa un ID fittizio per un nuovo wallet
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.transparent,
                        elevation: 0,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xffb3b3b3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Color(0xffb3b3b3),
                                  size: 50,
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget buildItem(BuildContext context, int index, double title, String body,
      String valuta) {
    final isSelected = selectedIndices.contains(index);
    final walletId = data[index].id;

    return GestureDetector(
      //per eliminazione multipla di wallet, manca la funzione del db
      onLongPress: () {
/*         setState(() {
          if (isSelected) {
            selectedIndices.remove(index);
          } else {
            selectedIndices.add(index);
          }
        }); */
      },
      onTap: () {
        if (selectedIndices.isNotEmpty) {
          setState(() {
            if (isSelected) {
              selectedIndices.remove(index);
            } else {
              selectedIndices.add(index);
            }
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNotePage(
                onSave: (newTitle, newBody) {
                  addOrEditNote(
                    context: context,
                    index: index,
                    title: newTitle,
                    body: newBody,
                  );
                  Navigator.pop(
                      context); // Chiudi AddNotePage dopo il salvataggio
                },
                initialTitle: title,
                initialBody: body,
                onDelete: () {
                  deleteNote(
                      index); // Chiama deleteNote quando viene attivato onDelete
                  Navigator.pop(
                      context); // Chiudi AddNotePage dopo la cancellazione
                },
                walletId: walletId!, // Passa l'ID del wallet corrente
              ),
            ),
          );
        }
      },
      key: ValueKey(index),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.red : Color(0xffb3b3b3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Bilancio: ",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "${formatNumber(title)} $valuta",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
