import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';

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
            text: initialTitle != null ? initialTitle.toString() : null),
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
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
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
                Divider(height: 1, color: Color(0xffb3b3b3)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: widget.bodyController,
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
                          hintText: 'Wallet Name',
                          hintStyle: TextStyle(
                            fontFamily: 'RobotoThin',
                            fontSize: 25,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0),
                      color: _hasTransactions ? Colors.grey.shade200 : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: widget.titleController,
                        style: TextStyle(
                          fontFamily: 'RobotoThin',
                          fontSize: 25,
                          color: _hasTransactions ? Colors.grey : Colors.black,
                        ),
                        onChanged: (_) {
                          setState(() {
                            _isDirty = true;
                          });
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Start Balance (€)',
                          hintStyle: TextStyle(
                            fontFamily: 'RobotoThin',
                            fontSize: 25,
                            color:
                                _hasTransactions ? Colors.grey : Colors.black,
                          ),
                          border: InputBorder.none,
                        ),
                        enabled:
                            !_hasTransactions, // Disabilita se ci sono transazioni
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
                  side: BorderSide(color: Color(0xffb3b3b3), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saveNote,
              child: widget.initialTitle == null && widget.initialBody == null
                  ? Text("Aggiungi")
                  : Text("Modifica"),
            ),
          ),
        ),
      ),
    );
  }

  void _saveNote() {
    if (widget.titleController.text.isNotEmpty &&
        widget.bodyController.text.isNotEmpty) {
      double title;
      if (!_hasTransactions) {
        title = double.parse(widget.titleController.text);
      } else {
        title = widget.initialTitle!;
      }

      widget.onSave(title, widget.bodyController.text);
      setState(() {
        _isDirty = false;
      });
      _showSnackbar(
          context,
          widget.initialTitle == null && widget.initialBody == null
              ? 'Wallet creato con successo'
              : 'Wallet modificato con successo');
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
            'Sei sicuro di voler eliminare questo wallet? Questa azione non può essere annullata.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Sì'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.onDelete != null) {
      widget.onDelete!();
      _showSnackbar(context, 'Wallet eliminato con successo');
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
