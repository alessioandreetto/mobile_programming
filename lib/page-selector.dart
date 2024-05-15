import 'package:flutter/material.dart';

import 'pages/home.dart';
import 'pages/charts.dart';
import 'pages/wallet.dart';
import 'pages/setting.dart';

import 'pages/new_operation.dart';

import 'fab.dart';

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
      // floatingActionButton: FabPieMenu(),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          shape: CircleBorder(),
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NewOperation()), 
            );
          }),
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
}
