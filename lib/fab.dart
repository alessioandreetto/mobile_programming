import 'package:flutter/material.dart';
import 'dart:math' as math;

class FabPieMenu extends StatefulWidget {
  @override
  _FabMenuState createState() => _FabMenuState();
}

class _FabMenuState extends State<FabPieMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:  Stack(
            alignment: Alignment.bottomCenter,
            children: [
              GestureDetector(
                onTap: _toggleMenu,
                child: _buildMenu(),
              ),
            ],
          ),

 
    );
  }

  Widget _buildMenu() {
    return SafeArea(child: 
    Stack(
      children: [
          FloatingActionButton(
            shape: CircleBorder(),
            elevation: 0,
            onPressed: _toggleMenu,
            child: Icon(_isMenuOpen ? Icons.close : Icons.add),
          ),
          if (_isMenuOpen) ...[
            _buildMenuButton(Icons.north_east, _degreeToRadian(30), 80, 0),
            _buildMenuButton(Icons.currency_exchange, _degreeToRadian(90), 80, 1),
            _buildMenuButton(Icons.south_west, _degreeToRadian(150), 80, 2),
          ],
        ],
      ),
    );
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });

    if (_isMenuOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Widget _buildMenuButton(IconData icon, double angle, double radius, int index) {
    return Transform(
      transform: Matrix4.translationValues(
        radius * math.cos(angle),
        radius * math.sin(angle),
        0.0,
      ),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.0, 1.0, curve: Curves.easeOut),
        ),
        child: FloatingActionButton(
          shape: CircleBorder(),
          onPressed: () {
            print('index: $index');
            _toggleMenu();
          },
          child: Icon(icon),
        ),
      ),
    );
  }

  double _degreeToRadian(double degree) {
    return degree * math.pi / -180;
  }
}
