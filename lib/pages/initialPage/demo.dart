import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/initialPage/first_wallet.dart';
import 'package:flutter_application_1/pages/initialPage/welcome_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../page-selector.dart';
import '../../model/database_model.dart';
import '../../providers/wallet_provider.dart';
import 'package:provider/provider.dart';

class PageIndicatorDemo extends StatefulWidget {
  @override
  _PageIndicatorDemoState createState() => _PageIndicatorDemoState();
}

class _PageIndicatorDemoState extends State<PageIndicatorDemo> {
  PageController _pageController = PageController();
  int _currentPageIndex = 0;
  String walletName = '';
  double walletBalance = 0.0;
  int? walletId;

  void _updateWalletData(String name, double balance, {int? id}) {
    setState(() {
      walletName = name;
      walletBalance = balance;
      walletId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Aggiungi questa linea
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              children: [
                Container(
                  child: Center(
                    child: WelcomePage(),
                  ),
                ),
                Container(
                  child: Center(
                    child: FirstWallet(
                      onWalletDataChanged: (name, balance) {
                        _updateWalletData(name, balance);
                      },
                    ),
                  ),
                ),
                Container(
                  color: Colors.orange,
                  child: Center(
                    child: Text('Page 3'),
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
                          border: Border.all(color: Colors.black, width: 1),
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
                  SizedBox(
                      width: 48), // Lascia lo spazio se siamo alla prima pagina
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 4, // Numero totale di pagine
                  effect: WormEffect(), // Effetto desiderato
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
                  SizedBox(
                      width: 48), // Lascia lo spazio se siamo all'ultima pagina
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveTutorialCompletion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstTimeUser', false);
  }

  void _onTutorialCompleted() {
    _saveTutorialCompletion();

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

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => BottomBarDemo(),
    ));
  }
}
