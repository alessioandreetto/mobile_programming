import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'pages/charts.dart';
import 'pages/wallet.dart';
import 'pages/setting.dart';
import 'providers/wallet_provider.dart';
import 'pages/new_operation.dart';

class BottomBarDemo extends StatefulWidget {
  @override
  _BottomBarDemoState createState() => _BottomBarDemoState();
}

class _BottomBarDemoState extends State<BottomBarDemo> {
  int _selectedIndex = 0;

  late AnimationController _animationController;
  bool _isMenuOpen = false;

  final List<Widget> _widgetOptions = <Widget>[
    MyHomePage(),
    ChartsPage(),
    WalletPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavBarItem(Icons.home, 0, 'Home'),
            _buildNavBarItem(Icons.show_chart, 1, 'Charts'),
            SizedBox(width: 40), // Spazio vuoto per il notch centrale
            _buildNavBarItem(Icons.wallet, 2, 'Wallet'),
            _buildNavBarItem(Icons.settings, 3, 'Settings'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          bool hasWallets = walletProvider.wallets.isNotEmpty;
          return FloatingActionButton(
            onPressed: hasWallets
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewTransactionPage()),
                    );
                  }
                : () {
                    _showSnackbar(context);
                  },
            child: Icon(
              Icons.add,
              //color: Colors.white,
            ),
            //backgroundColor: Colors.grey, // Cambiato da blue a grey
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, int index, String label) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _selectedIndex == index ? Colors.blue : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index ? Colors.blue : Colors.grey,
                fontWeight: _selectedIndex == index
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
          'Impossibile aggiungere nuova transazione!\nCreare prima un nuovo wallet!'),
      duration: Duration(seconds: 2), // Imposta la durata della snackbar
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
