import 'package:flutter/material.dart';

class ScreenCheckPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _FullScreenDetectorPageState createState() => _FullScreenDetectorPageState();
}

class _FullScreenDetectorPageState extends State<ScreenCheckPage> {
  int _colorIndex = 0;
  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.white,
  ];

  void _changeColor() {
    setState(() {
      if (_colorIndex < _colors.length - 1) {
        _colorIndex++;
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeColor,
      child: Scaffold(
        backgroundColor: _colors[_colorIndex],
        body: Container(),
      ),
    );
  }
}