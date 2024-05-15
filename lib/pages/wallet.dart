import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'new_wallet.dart';
import '../model/database_model.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class Note {
  String title;
  String body;

  Note({
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      body: json['body'],
    );
  }
}

class _WalletPageState extends State<WalletPage> {
  List<Note> data = [];
  Set<int> selectedIndices = Set();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    List<Wallet> wallets = await DatabaseHelper().getWallets();
    setState(() {
      data = wallets.map((wallet) => Note(title: wallet.name!, body: wallet.balance.toString())).toList();
    });
  }

  void _saveNotes() async {
    List<Wallet> wallets = data.map((note) => Wallet(name: note.title, balance: note.body)).toList();
    wallets.forEach((wallet) async {
      await DatabaseHelper().insertWallet(wallet);
    });
  }

/*   void deleteNote(int index) async {
    await DatabaseHelper().deleteWallet(data[index].title);
    setState(() {
      data.removeAt(index);
    });
  }

  void deleteSelectedNotes() {
    setState(() {
      List<int> indicesToRemove = selectedIndices.toList();
      indicesToRemove.sort((a, b) => b.compareTo(a));
      for (int index in indicesToRemove) {
        deleteNote(index);
      }
      selectedIndices.clear();
      _saveNotes();
    });
  } */

  void addOrEditNote({
    required int index,
    required String title,
    required String body,
  }) async {
    Wallet wallet = Wallet(name: title, balance: body);
    if (index >= 0 && index < data.length) {
      await DatabaseHelper().updateWallet(wallet);
      setState(() {
        data[index] = Note(title: title, body: body);
      });
    } else {
      await DatabaseHelper().insertWallet(wallet);
      print('wallet');
      setState(() {
        data.add(Note(title: title, body: body));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Wallets',
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
              onPressed: (){},
            /*   onPressed: deleteSelectedNotes, */
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(
            height: 0.5,
            color: Color(0xffb3b3b3),
          ),
          Expanded(
            child: ReorderableGridView.count(
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              crossAxisCount: 2,
              children: data.map((note) {
                final index = data.indexOf(note);
                return buildItem(index, note.title, note.body);
              }).toList(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final movedItem = data.removeAt(oldIndex);
                  data.insert(newIndex, movedItem);
                  _saveNotes();
                });
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
                              index: -1,
                              title: title,
                              body: body,
                            );
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  child: Card(
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
                              color: Color(0xff262626),
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
      ),
    );
  }

  Widget buildItem(int index, String title, String body) {
    final isSelected = selectedIndices.contains(index);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          if (isSelected) {
            selectedIndices.remove(index);
          } else {
            selectedIndices.add(index);
          }
        });
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
        } /* else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNotePage(
                onSave: (newTitle, newBody) {
                  addOrEditNote(
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
              ),
            ),
          );
        } */
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
                      fontFamily: 'RobotoThin',
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
                        "Balance: ",
                        style: TextStyle(
                          fontFamily: 'RobotoThin',
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "$title €",
                        style: TextStyle(
                          fontFamily: 'RobotoThin',
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
