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
                    _showSnackbar(context,
                        'Impossibile aggiungere nuova transazione!\nCreare prima un nuovo wallet!');
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

  void _showSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0, // Posiziona il messaggio a 50 pixel dall'alto
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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

    // Rimuove il messaggio dopo 2 secondi
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
