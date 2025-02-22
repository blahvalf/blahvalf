import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _output = "0";
  double _num1 = 0;
  double _num2 = 0;
  String _operation = ""; 
  bool _isOperationPressed = false; 

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == "AC") {
        _output = "0";
        _num1 = 0;
        _num2 = 0;
        _operation = "";
        _isOperationPressed = false;
      }else if (buttonText == "⌫") { 
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
          
          if (_output.endsWith(".") && !_output.contains(RegExp(r'\d\.'))) {
            _output = _output.substring(0, _output.length - 1);
          }
        } else {
          _output = "0";
        }
      }else if (buttonText == "%") {
        _output = (double.parse(_output) / 100).toString();
      } else if (buttonText == ".") {
        if (!_output.contains(".")) {
          _output += ".";
        }
      } else if (buttonText == "=") {
        _num2 = double.parse(_output);
        if (_operation == "+") {
          _output = (_num1 + _num2).toString();
        } else if (_operation == "-") {
          _output = (_num1 - _num2).toString();
        } else if (_operation == "×") {
          _output = (_num1 * _num2).toString();
        } else if (_operation == "÷") {
          _output = (_num1 / _num2).toString();
        }
        _num1 = 0;
        _num2 = 0;
        _operation = "";
        _isOperationPressed = false;
      } else if (["+", "-", "×", "÷"].contains(buttonText)) {
        if (_isOperationPressed) {
          _num2 = double.parse(_output);
          if (_operation == "+") {
            _output = (_num1 + _num2).toString();
          } else if (_operation == "-") {
            _output = (_num1 - _num2).toString();
          } else if (_operation == "×") {
            _output = (_num1 * _num2).toString();
          } else if (_operation == "÷") {
            _output = (_num1 / _num2).toString();
          }
          _num1 = double.parse(_output);
        } else {
          _num1 = double.parse(_output);
        }
        _operation = buttonText;
        _isOperationPressed = true;
        _output = "0";
      } else {
        if (_output == "0" || _isOperationPressed) {
          _output = buttonText;
        } else {
          _output += buttonText;
        }
        _isOperationPressed = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Calculator'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Text(
                _output,
                style: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton("AC", context),
                    _buildButton("⌫", context),
                    _buildButton("%", context),
                    _buildButton("÷", context),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("7", context),
                    _buildButton("8", context),
                    _buildButton("9", context),
                    _buildButton("×", context),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("4", context),
                    _buildButton("5", context),
                    _buildButton("6", context),
                    _buildButton("-", context),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("1", context),
                    _buildButton("2", context),
                    _buildButton("3", context),
                    _buildButton("+", context),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("0", context, flex: 2),
                    _buildButton(".", context),
                    _buildButton("=", context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, BuildContext context, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(text),
          child: Text(
            text,
            style: TextStyle(fontSize: 24.0),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
      ),
    );
  }
}