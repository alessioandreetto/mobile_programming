import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/wallet_provider.dart';
import 'SettingsPage/change_name.dart'; // Assicurati che il percorso sia corretto
import 'initialPage/welcome_page.dart';
import 'initialPage/demo.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedValuta;

  @override
  void initState() {
    super.initState();
    _loadValutaFromSharedPreferences();
  }

  Future<void> _loadValutaFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedValuta = prefs.getString('valuta') ??
          '\$'; // Valore predefinito se non c'è nessun valore salvato
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xffb3b3b3),
              ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: ListTile(
              title: Text('Change Account name'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeNamePage()),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xffb3b3b3),
              ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: ListTile(
              title: Text('Cambia valuta'),
              onTap: () {},
              trailing: DropdownButton<String>(
                value: _selectedValuta,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedValuta = newValue!;
                  });
                  _saveValutaToSharedPreferences(newValue!);
                },
                items: <String>['€', '\$', '£']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        
            Container(
            margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xffb3b3b3),
              ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: ListTile(
              title: Text('test tutorial iniziale'),
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PageIndicatorDemo()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveValutaToSharedPreferences(String newValuta) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('valuta', newValuta);
    _selectedValuta = newValuta; // Aggiornamento locale del valore selezionato
    Provider.of<WalletProvider>(context, listen: false)
        .updateValuta(newValuta); // Avviso del cambio di valuta al provider
  }
}
