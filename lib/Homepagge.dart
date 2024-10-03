import 'package:flutter/material.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController amountController = TextEditingController();
  String fromCurrency = 'USD';
  String toCurrency = 'IDR';
  String result = '';
  List<String> conversionHistory = [];
  List<String> favoriteConversions = [];
  bool isDarkTheme = true;

  Map<String, double> currencyRates = {
    'USD': 1.0,
    'EUR': 0.85,
    'IDR': 15000.0,
    'JPY': 110.0,
    'GBP': 0.75,
  };

  Map<String, String> currencyNames = {
    'USD': 'United States Dollar',
    'EUR': 'Euro',
    'IDR': 'Indonesian Rupiah',
    'JPY': 'Japanese Yen',
    'GBP': 'British Pound',
  };

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 20))
      ..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  void convertCurrency() {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    double amount = double.parse(amountController.text);
    double fromRate = currencyRates[fromCurrency]!;
    double toRate = currencyRates[toCurrency]!;
    double convertedAmount = (amount / fromRate) * toRate;

    setState(() {
      result = '$amount $fromCurrency = ${convertedAmount.toStringAsFixed(2)} $toCurrency';
      conversionHistory.add(result);
    });
  }

  void resetFields() {
    amountController.clear();
    setState(() {
      fromCurrency = 'USD';
      toCurrency = 'IDR';
      result = '';
      conversionHistory.clear();
      favoriteConversions.clear();
    });
  }

  void addToFavorites() {
    if (result.isNotEmpty && !favoriteConversions.contains(result)) {
      setState(() {
        favoriteConversions.add(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to favorites')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conversion already in favorites or empty')),
      );
    }
  }

  void removeFromFavorites(String conversion) {
    setState(() {
      favoriteConversions.remove(conversion);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed from favorites')),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkTheme ? Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Currency Converter',
          style: TextStyle(
            fontSize: 28,
            color: isDarkTheme ? Colors.white : Colors.black,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade900,
                    Colors.purple.shade900,
                    Colors.pink.shade700,
                    Colors.orange.shade700,
                  ],
                  stops: [
                    (0.1 + sin(_animation.value) * 0.1).clamp(0.0, 1.0),
                    (0.4 + cos(_animation.value) * 0.1).clamp(0.0, 1.0),
                    (0.7 + sin(_animation.value) * 0.1).clamp(0.0, 1.0),
                    1.0,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkTheme ? Icons.light_mode : Icons.dark_mode,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
            onPressed: () {
              setState(() {
                isDarkTheme = !isDarkTheme;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.swap_horiz, color: isDarkTheme ? Colors.white : Colors.black),
            onPressed: () {
              setState(() {
                String temp = fromCurrency;
                fromCurrency = toCurrency;
                toCurrency = temp;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [Colors.blueAccent, Colors.transparent],
                          radius: 2.5,
                          stops: [0.5, 1],
                          center: Alignment.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  _buildCurrencyDescription(),
                  SizedBox(height: 20),
                  _buildGlowingInputField(),
                  SizedBox(height: 20),
                  _buildDropdown('From Currency', fromCurrency, (value) {
                    setState(() {
                      fromCurrency = value!;
                    });
                  }),
                  SizedBox(height: 20),
                  _buildDropdown('To Currency', toCurrency, (value) {
                    setState(() {
                      toCurrency = value!;
                    });
                  }),
                  SizedBox(height: 30),
                  _buildAnimatedButton(),
                  SizedBox(height: 20),
                  result.isNotEmpty ? _buildResultDisplay() : SizedBox(),
                  result.isNotEmpty ? SizedBox(height: 20) : SizedBox(),
                  result.isNotEmpty ? _buildFavoriteButton() : SizedBox(),
                  SizedBox(height: 20),
                  _buildResetButton(),
                  SizedBox(height: 30),
                  _buildHistoryDisplay(),
                  SizedBox(height: 30),
                  _buildFavoriteConversions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDescription() {
    return Text(
      'Select the currencies you want to convert',
      style: TextStyle(
        fontSize: 18,
        color: isDarkTheme ? Colors.white : Colors.black,
        fontFamily: 'Orbitron',
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget _buildGlowingInputField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade900,
            Colors.purple.shade900,
            Colors.pink.shade700,
            Colors.orange.shade700,
          ],
          stops: [
            0.1,
            0.4,
            0.7,
            1.0,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextField(
          controller: amountController,
          style: TextStyle(
            fontSize: 24,
            color: isDarkTheme ? Colors.black : Colors.white,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter amount',
            hintStyle: TextStyle(
              fontSize: 18,
              color: isDarkTheme ? Colors.black : Colors.black,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isDarkTheme ? Colors.white : Colors.black,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDarkTheme ? Colors.black : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
              dropdownColor: isDarkTheme ? Colors.black : Colors.white,
              onChanged: onChanged,
              items: currencyRates.keys.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(
                    '$currency - ${currencyNames[currency]}',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedButton() {
    return InkWell(
      onTap: convertCurrency,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade900,
              Colors.pink.shade700,
              Colors.orange.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.6),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Convert',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultDisplay() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDarkTheme ? Colors.grey.shade900 : Colors.grey.shade300,
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.6),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        result,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          color: isDarkTheme ? Colors.white : Colors.black,
          fontFamily: 'Orbitron',
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return InkWell(
      onTap: addToFavorites,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade900,
              Colors.pink.shade700,
              Colors.orange.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.6),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Add to Favorites',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return InkWell(
      onTap: resetFields,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade900,
              Colors.pink.shade700,
              Colors.orange.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.6),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Reset',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Conversion History',
          style: TextStyle(
            fontSize: 18,
            color: isDarkTheme ? Colors.white : Colors.black,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        conversionHistory.isEmpty
            ? Text(
                'No conversions yet.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: conversionHistory.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isDarkTheme ? Colors.grey.shade900 : Colors.grey.shade300,
                      ),
                      child: Text(
                        conversionHistory[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildFavoriteConversions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Favorite Conversions',
          style: TextStyle(
            fontSize: 18,
            color: isDarkTheme ? Colors.white : Colors.black,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        favoriteConversions.isEmpty
            ? Text(
                'No favorites yet.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: favoriteConversions.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      removeFromFavorites(favoriteConversions[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isDarkTheme ? Colors.grey.shade900 : Colors.grey.shade300,
                        ),
                        child: Text(
                          favoriteConversions[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
