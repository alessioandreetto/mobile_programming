import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirstWallet extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController balanceController;
  final Function(String, double) onWalletDataChanged;
  final bool isNameValid;
  final bool isBalanceValid;

  FirstWallet({
    required this.nameController,
    required this.balanceController,
    required this.onWalletDataChanged,
    required this.isNameValid,
    required this.isBalanceValid,
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
    setState(() {
      _isDirty = true;
    });
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
                      Text('Crea qui il tuo primo portafoglio!',
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: widget.nameController,
                            onChanged: (_) {
                              setState(() {
                                _isDirty = true;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Nome del portafoglio',
                              errorText: widget.isNameValid
                                  ? null
                                  : 'Questo campo è obbligatorio',
                              suffixIcon: widget.isNameValid
                                  ? null
                                  : Icon(Icons.error, color: Colors.red),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: widget.balanceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            onChanged: (_) {
                              setState(() {
                                _isDirty = true;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Bilancio iniziale',
                              errorText: widget.isBalanceValid
                                  ? null
                                  : 'Questo campo è obbligatorio',
                              suffixIcon: widget.isBalanceValid
                                  ? null
                                  : Icon(Icons.error, color: Colors.red),
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
      return await _showConfirmationDialog();
    }
    return true;
  }

  Future<bool> _showConfirmationDialog() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Conferma'),
            content: Text(
                'Sei sicuro di voler tornare indietro? I dati inseriti andranno persi.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Sì'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
