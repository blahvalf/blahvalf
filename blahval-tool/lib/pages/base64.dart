import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class Base64Page extends StatefulWidget {
  @override
  _Base64PageState createState() => _Base64PageState();
}

class _Base64PageState extends State<Base64Page> {
  TextEditingController _inputController = TextEditingController();
  String _outputText = '';
  bool _isUrlSafe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Base64'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _inputController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Input',
                border: OutlineInputBorder(),
                hintText: 'Text',
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: _isUrlSafe,
                  onChanged: (value) => setState(() => _isUrlSafe = value),
                ),
                Text('URL Safe'),
                IconButton(
                  icon: Icon(Icons.info_outline, size: 18),
                  onPressed: () => showInfoDialog(context),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _encodeBase64,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(120, 48),
                  ),
                  child: Text('Encode'),
                ),
                ElevatedButton(
                  onPressed: _decodeBase64,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(120, 48),
                  ),
                  child: Text('Decode'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Res: ${_outputText.length} chars'),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: _copyOutput,
                      tooltip: 'Copy',
                    ),
                    IconButton(
                      icon: Icon(Icons.clear_all),
                      onPressed: _clearAll,
                      tooltip: 'ClearAll',
                    ),
                  ],
                )
              ],
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _outputText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _encodeBase64() {
    final text = _inputController.text;
    if (text.isEmpty) return;
    
    var base64Str = base64.encode(utf8.encode(text));
    
    if (_isUrlSafe) {
      base64Str = base64Str
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
    }

    setState(() => _outputText = base64Str);
  }

  void _decodeBase64() {
    final text = _inputController.text;
    if (text.isEmpty) return;
    
    try {
      var input = text;
      if (_isUrlSafe) {
        input = input.replaceAll('-', '+').replaceAll('_', '/');
        switch (input.length % 4) {
          case 2:
            input += '==';
            break;
          case 3:
            input += '=';
            break;
        }
      }

      setState(() {
        _outputText = utf8.decode(base64.decode(input));
      });
    } catch (e) {
      setState(() => _outputText = 'Decode Err: ${e.toString()}');
    }
  }

  void _copyOutput() {
    if (_outputText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _outputText));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copyed')),
      );
    }
  }

  void _clearAll() {
    _inputController.clear();
    setState(() => _outputText = '');
  }

  void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('URL Safe Info'),
        content: Text('After enable:\n'
            '• "+" → "-"\n'
            '• "/" → "_"\n'
            '• delete "="\n\n'
            'Auto Padding when Decode'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Y'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}