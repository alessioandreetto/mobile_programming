import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/wallet_provider.dart';
import 'SettingsPage/change_name.dart';
import 'initialPage/demo.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedValuta;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadValutaFromSharedPreferences();
    _loadThemeMode();
  }

  Future<void> _loadValutaFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedValuta = prefs.getString('valuta') ?? '€';
    });
  }

  Future<void> _loadThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      _isDarkMode = savedThemeMode == AdaptiveThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Impostazioni'),
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
            ),
            child: ListTile(
              title: Text('Modifica nome account'),
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
  /*         Container(
            margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xffb3b3b3),
              ),
              borderRadius: BorderRadius.circular(10),
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
          ), */
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xffb3b3b3),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text('Modalità scura'),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  if (_isDarkMode) {
                    AdaptiveTheme.of(context).setDark();
                  } else {
                    AdaptiveTheme.of(context).setLight();
                  }
                },
              ),
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
