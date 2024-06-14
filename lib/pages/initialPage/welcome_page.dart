import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';

class WelcomePage extends StatefulWidget {
  final Function(String)
      onNameEntered; // Callback per notificare il nome inserito

  WelcomePage({required this.onNameEntered});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late TextEditingController _nameController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late PageController _pageController;
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _pageController = PageController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final provider = Provider.of<WalletProvider>(context, listen: false);
      if (provider.name != 'User') {
        _nameController.text = provider.name;
        _isButtonDisabled = _nameController.text.isEmpty;
      }
    });

    _nameController.addListener(() {
      setState(() {
        _isButtonDisabled = _nameController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onSwipe(int pageIndex) {
    if (_formKey.currentState!.validate()) {
      _pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: PageView(
          controller: _pageController,
          physics: _isButtonDisabled
              ? NeverScrollableScrollPhysics()
              : AlwaysScrollableScrollPhysics(),
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Benvenuto! Inizia il tuo viaggio finanziario.',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Inserisci il tuo nome per iniziare',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserire il nome';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Aggiorna il nome nel provider quando cambia
                      Provider.of<WalletProvider>(context, listen: false)
                          .updateAccountName(value);
                    },
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
            // Aggiungi altre pagine qui
            Center(
              child: Text('Pagina successiva'),
            ),
          ],
          onPageChanged: (index) {
            if (index == 1 && _isButtonDisabled) {
              _pageController.animateToPage(
                0,
                duration: Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            }
          },
        ),
      ),
    );
  }
}
