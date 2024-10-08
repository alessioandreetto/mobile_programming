import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';
import '../../main.dart';

class WelcomePage extends StatefulWidget {
  final Function(String) onNameEntered;

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
        _isButtonDisabled = _nameController.text.trim().isEmpty;
      }
    });

    _nameController.addListener(() {
      setState(() {
        _isButtonDisabled = _nameController.text.trim().isEmpty;
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
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
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
                  counterText: '',
                ),
                maxLength: 15,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Inserire il nome';
                  } else if (value.length > 15) {
                    return 'Il nome non può superare i 15 caratteri';
                  }
                  return null;
                },
                onChanged: (value) {
                  Provider.of<WalletProvider>(context, listen: false)
                      .updateAccountName(value.trim());
                },
              ),
              SizedBox(height: 20.0),
              Text(
                'Con questa app semplice e intuitiva, '
                'potrai tenere traccia delle tue spese quotidiane '
                'e pianificare un futuro finanziario migliore. '
                'Inizia ad esplorare il mondo delle tue finanze oggi stesso!',
                style: TextStyle(
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
