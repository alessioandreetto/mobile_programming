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
        title: Text('Impostazioni', style: TextStyle(fontSize: 25)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
       /*  actions: <Widget>[
          // Italy Flag Icon
          IconButton(
            icon: Image.asset(
                'assets/images/it_flag.jpg'), // Replace with your asset path
            onPressed: () {
              // Add functionality if needed
            },
          ),
          // England Flag Icon
          IconButton(
            icon: Image.asset(
                'assets/images/uk_flag.jpg'), // Replace with your asset path
            onPressed: () {
              // Add functionality if needed
            },
          ),
        ], */
      ),
      body: ListView(
        children: <Widget>[
 
          Card(
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
          
          Card(
           
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
          Card(
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
 Card(
            child: ListTile(
              title: Text('tutorial demo'),
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
