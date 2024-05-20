import 'package:flutter/material.dart';

class ChartsPage extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  late String _selectedButton;

  @override
  void initState() {
    super.initState();
    _selectedButton = 'Today'; // Inizialmente selezionato 'Today'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome User'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 85,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedButton = 'Today';
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        return _selectedButton == 'Today'
                            ? Colors.orange
                            : Colors.grey[300]!;
                      }),
                    ),
                    child: Text('Today', style: TextStyle(fontSize: 12)),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedButton = 'Weekly';
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        return _selectedButton == 'Weekly'
                            ? Colors.orange
                            : Colors.grey[300]!;
                      }),
                    ),
                    child: Text('Weekly', style: TextStyle(fontSize: 12)),
                  ),
                ),
                SizedBox(
                  width: 95,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedButton = 'Monthly';
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        return _selectedButton == 'Monthly'
                            ? Colors.orange
                            : Colors.grey[300]!;
                      }),
                    ),
                    child: Text('Monthly', style: TextStyle(fontSize: 12)),
                  ),
                ),
                SizedBox(
                  width: 85,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedButton = 'Yearly';
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        return _selectedButton == 'Yearly'
                            ? Colors.orange
                            : Colors.grey[300]!;
                      }),
                    ),
                    child: Text('Yearly', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          // Aggiungi qui i tuoi grafici o altri widget sotto i pulsanti
        ],
      ),
    );
  }
}
