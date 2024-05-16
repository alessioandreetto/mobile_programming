import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddNotePage extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final Function(double title, String body) onSave;
  final VoidCallback? onDelete;
  final double? initialTitle; // Cambiato il tipo da String? a double?
  final String? initialBody;

  AddNotePage({
    required this.onSave,
    this.onDelete,
    this.initialTitle,
    this.initialBody,
  })  : titleController = TextEditingController(text: initialTitle != null ? initialTitle.toString() : null),
        bodyController = TextEditingController(text: initialBody);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  bool _isDirty = false; // Flag per indicare se ci sono modifiche non salvate

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Utilizza la funzione _onWillPop per gestire la navigazione all'indietro
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
                  onPressed: () {
                    if (widget.onDelete != null) {
                      widget.onDelete!();
                    }
                  },
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
                            _isDirty =
                                true; // Segna che ci sono modifiche non salvate
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
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: widget.titleController,
                        style: TextStyle(
                          fontFamily: 'RobotoThin',
                          fontSize: 25,
                        ),
                        onChanged: (_) {
                          setState(() {
                            _isDirty =
                                true; // Segna che ci sono modifiche non salvate
                          });
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Start Balance (€)',
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
    if (_isDirty && widget.initialTitle != null && widget.initialBody != null) {
      // Mostra un dialogo di conferma per chiedere all'utente se desidera salvare
      _saveNote(); // Salva la nota
    }

    return true; // Nessuna modifica da salvare, permetti l'uscita
  }

  void _saveNote() {
    if (widget.titleController.text.isNotEmpty &&
        widget.bodyController.text.isNotEmpty) {
      widget.onSave(double.parse(widget.titleController.text), widget.bodyController.text);
      setState(() {
        _isDirty = false; // Le modifiche sono state salvate
      });
    }
  }

  @override
  void dispose() {
    widget.titleController.dispose();
    widget.bodyController.dispose();
    super.dispose();
  }
}
