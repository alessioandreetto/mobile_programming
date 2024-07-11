import 'package:flutter/material.dart';
import 'dart:ui';
import '../homeList/HomeList.dart';

class InteractiveTutorial extends StatefulWidget {
  final Function onComplete;

  InteractiveTutorial({required this.onComplete});

  @override
  _InteractiveTutorialState createState() => _InteractiveTutorialState();
}

class _InteractiveTutorialState extends State<InteractiveTutorial> {
  int _currentStep = 0;
  bool _isBlurVisible = true;
  bool _isInfoVisible = true;

  void _nextStep() {
    setState(() {
      _isInfoVisible = false;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _currentStep++;
        _isInfoVisible = true;
        _isBlurVisible = true;
      });
    });
    setState(() {
      _isBlurVisible = false;
    });
  }

  void _skipTutorial() {
    widget.onComplete();
  }

  void _addTransaction() {
    setState(() {
      _currentStep++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/sfondo_tutorial.jpg'),
                      
                    ),
                  ),
                ),
              ),
              if (_isBlurVisible && (_currentStep >= 0 && _currentStep <= 5))
                _buildBlurBackground(),
              if (_isInfoVisible && _currentStep == 0) _buildStep1(constraints),
              if (_isInfoVisible && _currentStep == 1) _buildStep2(constraints),
              if (_isInfoVisible && _currentStep == 2) _buildStep3(constraints),
              if (_isInfoVisible && _currentStep == 3) _buildStep4(constraints),
              if (_currentStep == 4) _buildAddTransactionButton(),
              if (_isInfoVisible && _currentStep == 5) _buildStep5(constraints),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBlurBackground() {
    return AnimatedOpacity(
      opacity: _isBlurVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: Colors.black.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildStep1(BoxConstraints constraints) {
    return Positioned(
      left: 20,
      top: constraints.maxHeight * 0.1,
      child: Container(
        width: constraints.maxWidth - 40,
        color: Colors.black.withOpacity(0.1),
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
              '1. Questa è la Home! Qui puoi vedere il grafico a torta delle tue transazioni.',
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

  Widget _buildStep2(BoxConstraints constraints) {
    return Positioned(
      left: 20,
      top: constraints.maxHeight * 0.3,
      child: Container(
        width: constraints.maxWidth - 40,
        color: Colors.black.withOpacity(0.1),
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
              '2. In questa sezione puoi selezionare un portafoglio per visualizzare le sue transazioni.',
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

  Widget _buildStep3(BoxConstraints constraints) {
    return Positioned(
      left: 20,
      top: constraints.maxHeight * 0.6,
      child: Container(
        width: constraints.maxWidth - 40,
        color: Colors.black.withOpacity(0.1),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transazioni',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              '3. Qui invece puoi vedere tutte le tue transazioni! Toccando la transazione stessa puoi modificarla o eliminarla!',
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

  Widget _buildStep4(BoxConstraints constraints) {
    return Positioned(
      left: 20,
      top: constraints.maxHeight * 0.6,
      child: Container(
        width: constraints.maxWidth - 40,
        color: Colors.black.withOpacity(0.1),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nuova Transazione',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              '4. Per andare a creare una nuova transazione, clicca su prossimo +',
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

  Widget _buildAddTransactionButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          onPressed: _addTransaction,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildStep5(BoxConstraints constraints) {
    return Positioned(
      left: 20,
      top: constraints.maxHeight * 0.6,
      child: Container(
        width: constraints.maxWidth - 40,
        color: Colors.black.withOpacity(0.1),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Creazione Transazione',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              '5. Dopo aver cliccato + l\'app ti porterà alla pagina di creazione della nuova transazione! Ti basterà inserire correttamente tutti i dati e premere il pulsante "Aggiungi transazione" e il gioco è fatto!',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _skipTutorial,
              child: Text(
                'Prosegui',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
