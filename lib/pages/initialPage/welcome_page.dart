import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:sqflite/utils/utils.dart';
import 'first_wallet.dart';



class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  bool _typingDone = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText('Benvenuto! Inizia il tuo viaggio finanziario.'),
                      ],
                      totalRepeatCount: 1, // Ripeti solo una volta
                      onFinished: () {
                        setState(() {
                          _typingDone = true;
                          _controller.forward();
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
                  AnimatedOpacity(
                    opacity: _typingDone ? 1.0 : 0.0,
                    duration: Duration(seconds: 1),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Inserisci il tuo nome per iniziare',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          'Con questa app semplice e intuitiva, '
                          'potrai tenere traccia delle tue spese quotidiane '
                          'e pianificare un futuro finanziario migliore. '
                          'Inizia ad esplorare il mondo delle tue finanze oggi stesso!',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}
