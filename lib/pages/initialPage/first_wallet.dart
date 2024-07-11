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
            title:  Text(
                        'Crea qui il tuo primo portafoglio!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      SizedBox(height: 10),
                      Text(
                        'Inserisci qui sotto un nome significativo per il portafoglio che andrai a creare:',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: widget.nameController,
                        onChanged: (_) {
                          setState(() {
                            _isDirty = true;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Nome del portafoglio',
                          errorText:
                              widget.isNameValid ? null : 'Campo obbligatorio',
                          suffixIcon: widget.isNameValid
                              ? null
                              : Icon(Icons.error, color: Colors.red),
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
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: widget.balanceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                       CustomNumberInputFormatter(),
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
                              : 'Campo obbligatorio',
                          suffixIcon: widget.isBalanceValid
                              ? null
                              : Icon(Icons.error, color: Colors.red),
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
              'Sei sicuro di voler tornare indietro? I dati inseriti andranno persi.',
            ),
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


class CustomNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Handle empty input
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Split the input into integer and decimal parts
    final parts = newValue.text.split('.');

    // Check the integer part length
    if (parts[0].length > 9) {
      return oldValue;
    }

    // Check the decimal part length if it exists
    if (parts.length > 1 && parts[1].length > 2) {
      return oldValue;
    }

    // Check the total length
    if (newValue.text.length > 12) {
      return oldValue;
    }

    // Return the new value if it passes all checks
    return newValue;
  }
}
