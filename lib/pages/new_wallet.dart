import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart'; // Assicurati che il percorso sia corretto

class AddNotePage extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final Function(double title, String body) onSave;
  final VoidCallback? onDelete;
  final double? initialTitle;
  final String? initialBody;
  final int
      walletId; // Aggiungi walletId per identificare il portafoglio corrente

  AddNotePage({
    required this.onSave,
    this.onDelete,
    this.initialTitle,
    this.initialBody,
    required this.walletId, // Richiesto walletId nel costruttore
  })  : titleController = TextEditingController(
            text: initialTitle != null ? initialTitle.toString() : null),
        bodyController = TextEditingController(text: initialBody);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  bool _isDirty = false;
  bool _hasTransactions = false;

  @override
  void initState() {
    super.initState();
    _checkTransactions();
  }

  Future<void> _checkTransactions() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    bool hasTransactions =
        await walletProvider.hasTransactionsForWallet(widget.walletId);
    setState(() {
      _hasTransactions = hasTransactions;
    });
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
            actions: [
              if (widget.onDelete != null)
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

  Future<bool> _onWillPop() async {
    if (_isDirty) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Salvare le modifiche?'),
              content: Text(
                  'Hai delle modifiche non salvate. Vuoi salvarle prima di uscire?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    _saveNote();
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Sì'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
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
    }
  }

  Future<void> _confirmDelete() async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminare il wallet?'),
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
    }
  }

  @override
  void dispose() {
    widget.titleController.dispose();
    widget.bodyController.dispose();
    super.dispose();
  }
}
