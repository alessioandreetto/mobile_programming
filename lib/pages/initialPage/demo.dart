import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/initialPage/first_wallet.dart';
import 'package:flutter_application_1/pages/initialPage/welcome_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../page-selector.dart';
import '../../model/database_model.dart';
import '../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'tutorial.dart';
import 'package:flutter/services.dart';

class PageIndicatorDemo extends StatefulWidget {
  @override
  _PageIndicatorDemoState createState() => _PageIndicatorDemoState();
}

class _PageIndicatorDemoState extends State<PageIndicatorDemo> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  String walletName = ''; // Nome del wallet
  double walletBalance = 0.0;
  int? walletId;

  // Creazione dei controller
  late TextEditingController nameController;
  late TextEditingController balanceController;

    FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    balanceController = TextEditingController();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Status bar color
      statusBarIconBrightness: Brightness.dark, // Dark icons for light status bar
    ));
  }

  @override
  void dispose() {
    // Rilascia le risorse dei controller
    nameController.dispose();
    balanceController.dispose();
        _focusScopeNode.dispose(); // Disponi del nodo FocusScope
    super.dispose();
  }

  void _updateWalletData(String name, double balance, {int? id}) {
    setState(() {
      walletName = name; // Aggiorna il nome del wallet
      walletBalance = balance;
      walletId = id;
    });
  }

  void _saveWalletData() {
    if (walletName.isNotEmpty && walletBalance > 0) {
      Wallet newWallet = Wallet(
        id: walletId,
        name: walletName,
        balance: walletBalance,
      );

      if (walletId != null) {
        // Update existing wallet
        DatabaseHelper().updateWallet(newWallet).then((id) {
          Provider.of<WalletProvider>(context, listen: false).loadWallets();
        });
      } else {
        // Insert new wallet
        DatabaseHelper().insertWallet(newWallet).then((id) {
          Provider.of<WalletProvider>(context, listen: false).loadWallets();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          // Chiudi la tastiera se è aperta
          if (!_focusScopeNode.hasPrimaryFocus) {
            _focusScopeNode.unfocus();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: FocusScope(
                node: _focusScopeNode,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                    // Chiudi la tastiera quando cambia la pagina
                    _focusScopeNode.unfocus();
                  },
                  children: [
                    Container(
                      child: Center(
                        child: WelcomePage(
                          onNameEntered: (name) {
                            setState(() {
                              walletName = name;
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                      child: Center(
                        child: FirstWallet(
                          nameController: nameController,
                          balanceController: balanceController,
                          onWalletDataChanged: (name, balance) {
                            _updateWalletData(name, balance);
                          },
                        ),
                      ),
                    ),
                    Container(
                      child: Center(
                        child: InteractiveTutorial(
                          onComplete: () {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bene, è tutto pronto\nIniziamo!',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextButton(
                              onPressed: _onTutorialCompleted,
                              child: Text(
                                'Fine tutorial',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPageIndex != 0)
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                    )
                  else
                    SizedBox(width: 48),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 4,
                    effect: WormEffect(),
                  ),
                  if (_currentPageIndex != 3)
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                    )
                  else
                    SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTutorialCompletion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstTimeUser', false);
  }

  void _onTutorialCompleted() {
    _saveWalletData();
    _saveTutorialCompletion();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => BottomBarDemo(),
    ));
  }
}
