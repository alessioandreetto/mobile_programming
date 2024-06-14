import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirstWallet extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController balanceController;
  final Function(String, double) onWalletDataChanged;

  FirstWallet({
    required this.nameController,
    required this.balanceController,
    required this.onWalletDataChanged,
  });

  @override
  _FirstWalletState createState() => _FirstWalletState();
}

class _FirstWalletState extends State<FirstWallet> {
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_onDataChanged);
    widget.balanceController.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    widget.onWalletDataChanged(
      widget.nameController.text,
      double.tryParse(widget.balanceController.text) ?? 0.0,
    );
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_onDataChanged);
    widget.balanceController.removeListener(_onDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            elevation: 0,
          ),
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
                            controller: widget.nameController,
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
                        'Imposta un saldo iniziale da cui parti e da dove inizierai a tener traccia delle tue spese e delle tue entrate.',
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
                            controller: widget.balanceController,
                            keyboardType: TextInputType.number,
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
                              hintText: '0.00 €',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isDirty) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Conferma uscita'),
          content: Text(
              'Hai delle modifiche non salvate. Sei sicuro di voler uscire?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Si'),
            ),
          ],
        ),
      );
    }
    return true;
  }
}
