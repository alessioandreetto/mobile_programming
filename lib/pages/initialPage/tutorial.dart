import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../homeList/HomeList.dart';

class InteractiveTutorial extends StatefulWidget {
  @override
  _InteractiveTutorialState createState() => _InteractiveTutorialState();
}

class _InteractiveTutorialState extends State<InteractiveTutorial> {
  int _currentStep = 0;

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _skipTutorial() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          HomeList(), // HomePage content
          if (_currentStep == 0) _buildStep1(),
          if (_currentStep == 1) _buildStep2(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Positioned(
      left: 20,
      top: 100,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        color: Colors.black54,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benvenuto nel Tutorial!',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              '1. Questa è la pagina principale dove puoi vedere un grafico a torta delle tue transazioni.',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _nextStep,
              child: Text(
                'Continua',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Positioned(
      left: 20,
      top: 100,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        color: Colors.black54,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portafogli',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              '2. Puoi selezionare un portafoglio per visualizzare le sue transazioni.',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _nextStep,
              child: Text(
                'Continua',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
