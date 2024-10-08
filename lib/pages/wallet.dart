import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../model/database_model.dart';
import 'new_wallet.dart';
import '../providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

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

class _WalletPageState extends State<WalletPage> {
  List<Note> data = [];
  Set<int> selectedIndices = Set();

  @override
  void initState() {
    super.initState();
    Provider.of<WalletProvider>(context, listen: false).loadValuta();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    Provider.of<WalletProvider>(context, listen: false)
        .updateSelectedWalletIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Portafogli',
          style: TextStyle(fontSize: FontSize.titles),
          textAlign: TextAlign.start,
        ),
        elevation: 0,
        actions: [
          if (selectedIndices.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {},
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
                  onReorder: (oldIndex, newIndex) {},
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
                              walletId: -1,
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

  Widget buildItem(BuildContext context, int index, double title, String body, String valuta) {
  final isSelected = selectedIndices.contains(index);
  final walletId = data[index].id;

  return GestureDetector(
    onLongPress: () {},
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
                Navigator.pop(context);
              },
              initialTitle: title,
              initialBody: body,
              onDelete: () {
                deleteNote(index);
                Navigator.pop(context);
              },
              walletId: walletId!,
            ),
          ),
        );
      }
    },
    key: ValueKey(index),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          // Main wallet container
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.red : Color(0xffb3b3b3),
                width: 2, // Slightly thicker border
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
                        fontSize: FontSize.listTitle,
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
                            fontSize: FontSize.secondaryText,
                          ),
                        ),
                        Text(
                          "${formatNumber(title)} $valuta",
                          style: TextStyle(
                            fontSize: FontSize.secondaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // fibbia del portafogli
          Positioned(
            right: -10,
            top: 60,
            child: Container(
              width: 70,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color:  Color(0xffb3b3b3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color:  Color(0xffb3b3b3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}