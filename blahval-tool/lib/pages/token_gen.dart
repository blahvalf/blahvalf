import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';


class TokenGenPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _TokenGenPageState createState() => _TokenGenPageState();
}

class _TokenGenPageState extends State<TokenGenPage> {
  bool _uppercase = true;
  bool _lowercase = true;
  bool _numbers = true;
  bool _symbols = true;
  
  final TextEditingController _lengthController = TextEditingController(text: '12');
  final TextEditingController _tokenController = TextEditingController();

  final String _upperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final String _lowerCaseChars = 'abcdefghijklmnopqrstuvwxyz';
  final String _numberChars = '0123456789';
  final String _symbolChars = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

  @override
  void initState() {
    super.initState();
    _generateToken();
  }

  void _generateToken() {
    String charPool = '';
    
    if (_uppercase) charPool += _upperCaseChars;
    if (_lowercase) charPool += _lowerCaseChars;
    if (_numbers) charPool += _numberChars;
    if (_symbols) charPool += _symbolChars;

    if (charPool.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Must Select One Char Type'))
      );
      return;
    }

    final length = int.tryParse(_lengthController.text) ?? 12;
    final random = Random();
    String token = '';
    
    for (int i = 0; i < length; i++) {
      token += charPool[random.nextInt(charPool.length)];
    }

    setState(() {
      _tokenController.text = token;
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _tokenController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copyed'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Token Gen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSwitchTile('ABC...', _uppercase, (v) => setState(() => _uppercase = v)),
            _buildSwitchTile('bc...', _lowercase, (v) => setState(() => _lowercase = v)),
            _buildSwitchTile('123...', _numbers, (v) => setState(() => _numbers = v)),
            _buildSwitchTile('!-;...', _symbols, (v) => setState(() => _symbols = v)),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('Len:', style: TextStyle(fontSize: 16)),
                ),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _lengthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.copy),
                    label: Text('Copy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _copyToClipboard,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _generateToken,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 25),
            
            TextField(
              controller: _tokenController,
              readOnly: true,
              maxLines: 6,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Token',
                suffixIcon: IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: _copyToClipboard,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}