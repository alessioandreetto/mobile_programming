import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirstWallet extends StatefulWidget {
  FirstWallet();

  @override
  _FirstWalletState createState() => _FirstWalletState();
}

class _FirstWalletState extends State<FirstWallet> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  bool _isDirty = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Crea qui il tuo primo wallet!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(height: 20),
                      Text(
                        'Inserisci qui sotto un nome significativo per il portafoglio che andrai a creare:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: bodyController,
                            style: TextStyle(
                              fontFamily: 'RobotoThin',
                              fontSize: 25,
                            ),
                            onChanged: (_) {
                              setState(() {
                                _isDirty = true;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Inserisci il nome del portafoglio',
                              hintStyle: TextStyle(
                                fontFamily: 'RobotoThin',
                                fontSize: 25,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Imposta un saldo iniziale da cui parti e da dove inizierai a tener traccia delle tue spese e dei tuoi guadagni:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: titleController,
                            style: TextStyle(
                              fontFamily: 'RobotoThin',
                              fontSize: 25,
                            ),
                            onChanged: (_) {
                              setState(() {
                                _isDirty = true;
                              });
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Inserisci il saldo iniziale',
                              hintStyle: TextStyle(
                                fontFamily: 'RobotoThin',
                                fontSize: 25,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isDirty) {
      _saveNote();
    }
    return true;
  }

  void _saveNote() {}

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }
}
