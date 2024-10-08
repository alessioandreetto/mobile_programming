import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/wallet_provider.dart';
import '../../main.dart';

class ChangeNamePage extends StatefulWidget {
  @override
  _ChangeNamePageState createState() => _ChangeNamePageState();
}

class _ChangeNamePageState extends State<ChangeNamePage> {
  TextEditingController _nameController = TextEditingController();
  bool _isDirty = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadNameFromSharedPreferences();
  }

  Future<void> _loadNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('account_name') ?? '';
    setState(() {
      _nameController.text = name.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Modifica nome account", style: TextStyle(fontSize: FontSize.titles)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(),
                      maxLength: 15,
                      onChanged: (text) {
                        setState(() {
                          _isDirty = true;
                          _errorText =
                              text.length > 15 ? 'Nome troppo lungo' : null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Nome account',
                        errorText: _errorText,
                        counterText: '',
                      ),
                    ),
                  ),
                ),
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
              onPressed: () => _saveName(context),
              child: Text("Salva" , style: TextStyle(fontSize: FontSize.buttons)),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isDirty && _nameController.text.isNotEmpty) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Conferma'),
              content: Text(
                  'Sei sicuro di voler tornare indietro senza salvare le modifiche?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Sì'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  void _saveName(BuildContext context) {
    if (_isDirty &&
        _nameController.text.isNotEmpty &&
        _nameController.text.length <= 15) {
      String newName = _nameController.text.trim();
      Provider.of<WalletProvider>(context, listen: false)
          .updateAccountName(newName);
      _saveNameToSharedPreferences(newName);
      setState(() {
        _isDirty = false;
      });
      Navigator.of(context).pop();
      _showSnackbar(context, 'Nome account modificato con successo');
    } else if (_nameController.text.length > 15) {
      setState(() {
        _errorText = 'Nome troppo lungo';
      });
    }
  }

  Future<void> _saveNameToSharedPreferences(String newName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('account_name', newName);
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
}
