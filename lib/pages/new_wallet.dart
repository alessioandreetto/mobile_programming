import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../main.dart';
class AddNotePage extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final Function(double title, String body) onSave;
  final VoidCallback? onDelete;
  final double? initialTitle;
  final String? initialBody;
  final int walletId;

  AddNotePage({
    required this.onSave,
    this.onDelete,
    this.initialTitle,
    this.initialBody,
    required this.walletId,
  })  : titleController = TextEditingController(
            text:
                initialTitle != null ? initialTitle.toStringAsFixed(2) : null),
        bodyController = TextEditingController(text: initialBody);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  bool _isDirty = false;
  bool _hasTransactions = false;
  bool _hideDeleteButton = false;

  @override
  void initState() {
    super.initState();
    _checkTransactions();
  }

  Future<void> _checkTransactions() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    int walletCount = await walletProvider.getWalletCount();
    bool hasTransactions =
        await walletProvider.hasTransactionsForWallet(widget.walletId);
    setState(() {
      _hasTransactions = hasTransactions;
      _hideDeleteButton = walletCount <= 1;
    });
  }

  void _showSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Future<void> _onBackPressed() async {
    if (_isDirty) {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Conferma uscita'),
          content: Text(
              'Hai delle modifiche non salvate. Sei sicuro di voler tornare indietro senza salvare?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Sì'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    var walletProvider = Provider.of<WalletProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          await _onBackPressed();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: widget.initialTitle == null && widget.initialBody == null
                ? Text("Nuovo Portafoglio", style: TextStyle(fontSize: FontSize.titles))
                : Text("Modifica Portafiglio", style: TextStyle(fontSize: FontSize.titles)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _onBackPressed,
            ),
            actions: [
              if (!_hideDeleteButton && widget.onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _confirmDelete,
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: widget.bodyController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onChanged: (_) {
                          setState(() {
                            _isDirty = true;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Nome portafoglio',
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _hasTransactions
                          ? (isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200)
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: widget.titleController,
                        style: TextStyle(
                          color: _hasTransactions
                              ? (isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey)
                              : (isDarkMode ? Colors.white : Colors.black),
                        ),
                        onChanged: (_) {
                          setState(() {
                            _isDirty = true;
                          });
                        },
                        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                        inputFormatters: [
                          CustomNumberInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Bilancio iniziale (${walletProvider.valuta})',
                        ),
                        enabled: !_hasTransactions,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: isDarkMode ? Colors.white70 : Color(0xffb3b3b3),
                      width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saveNote,
              child: widget.initialTitle == null && widget.initialBody == null
                  ? Text("Aggiungi" , style: TextStyle(fontSize: FontSize.buttons))
                  : Text("Modifica", style: TextStyle(fontSize: FontSize.buttons)),
            ),
          ),
        ),
      ),
    );
  }

  void _saveNote() {
    String trimmedTitle = widget.titleController.text.trim();
    String trimmedBody = widget.bodyController.text.trim();

    if (trimmedTitle.isNotEmpty && trimmedBody.isNotEmpty) {
      double title;
      if (double.tryParse(trimmedTitle) == null) {
        _showSnackbar(context, 'Inserire un valore numerico nel campo "Bilancio iniziale"');
        return;
      }

      if (!_hasTransactions) {
        title = double.parse(trimmedTitle);
      } else {
        title = widget.initialTitle!;
      }

      widget.onSave(title, trimmedBody);
      setState(() {
        _isDirty = false;
      });
      _showSnackbar(
          context,
          widget.initialTitle == null && widget.initialBody == null
              ? 'Portafoglio creato con successo'
              : 'Portafoglio modificato con successo');
    } else {
      _showSnackbar(context, 'Inserire tutti i campi');
    }
  }

  Future<void> _confirmDelete() async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conferma Eliminazione'),
        content: Text(
            'Sei sicuro di voler eliminare questo portafoglio? Questa azione non può essere annullata.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Sì'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('No'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.onDelete != null) {
      widget.onDelete!();
      _showSnackbar(context, 'Portafoglio eliminato con successo');
      Navigator.of(context).popUntil;
    }
  }

  @override
  void dispose() {
    widget.titleController.dispose();
    widget.bodyController.dispose();
    super.dispose();
  }
}
class CustomNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Converti la virgola in punto
    String newText = newValue.text.replaceAll(',', '.');

    // Se contiene più di un punto, mantieni il vecchio valore
    if (newText.indexOf('.') != newText.lastIndexOf('.')) {
      return oldValue;
    }

    // Se contiene un trattino '-', mantieni il vecchio valore
    if (newText.contains('-')) {
      return oldValue;
    }

    // Se il nuovo testo è vuoto, ritorna il nuovo valore con il testo modificato
    if (newText.isEmpty) {
      return newValue.copyWith(text: newText);
    }

    // Suddividi il testo in parti separate dal punto decimale
    final parts = newText.split('.');

    // Limita a 9 cifre intere
    if (parts[0].length > 9) {
      return oldValue;
    }

    // Limita a 2 cifre decimali
    if (parts.length > 1 && parts[1].length > 2) {
      return oldValue;
    }

    // Limita la lunghezza totale a 12 caratteri
    if (newText.length > 12) {
      return oldValue;
    }

    // Ritorna il valore modificato con il testo aggiornato
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}