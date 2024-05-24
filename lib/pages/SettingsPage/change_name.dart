import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/wallet_provider.dart';

class ChangeNamePage extends StatefulWidget {
  @override
  _ChangeNamePageState createState() => _ChangeNamePageState();
}

class _ChangeNamePageState extends State<ChangeNamePage> {
  TextEditingController _nameController = TextEditingController();
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    // Carica il nome quando il widget viene creato
    _loadNameFromSharedPreferences();
  }

  // Metodo per caricare il nome dalle SharedPreferences
  Future<void> _loadNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('account_name') ?? '';
    setState(() {
      _nameController.text = name; // Imposta il valore iniziale del campo di testo
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                      controller: _nameController,
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
                        hintText: 'Account Name',
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
            child: Text("Salva"),
          ),
        ),
      ),
    );
  }

  void _saveName(BuildContext context) {
    if (_isDirty && _nameController.text.isNotEmpty) {
      String newName = _nameController.text;
      Provider.of<WalletProvider>(context, listen: false).updateAccountName(newName);
      _saveNameToSharedPreferences(newName);
      setState(() {
        _isDirty = false;
      });
      Navigator.of(context).pop();
    }
  }

  // Metodo per salvare il nome nelle SharedPreferences
  Future<void> _saveNameToSharedPreferences(String newName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('account_name', newName);
  }
}
