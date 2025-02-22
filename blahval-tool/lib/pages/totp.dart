import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class CustomBase32 {
  static const String _charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  static List<int> decode(String input) {
    String cleanInput = input
        .replaceAll(RegExp(r'=+$'), '')
        .replaceAll(RegExp(r'\s'), '')
        .toUpperCase();

    if (!RegExp(r'^[A-Z2-7]*$').hasMatch(cleanInput)) {
      throw FormatException('包含非法Base32字符');
    }

    int byteLength = (cleanInput.length * 5) ~/ 8;
    List<int> result = List.filled(byteLength, 0);

    int buffer = 0;
    int bitsLeft = 0;
    int index = 0;

    for (int i = 0; i < cleanInput.length; i++) {
      int charValue = _charset.indexOf(cleanInput[i]);
      if (charValue == -1) continue;

      buffer = (buffer << 5) | charValue;
      bitsLeft += 5;

      if (bitsLeft >= 8) {
        bitsLeft -= 8;
        result[index++] = (buffer >> bitsLeft) & 0xFF;
      }
    }

    return result;
  }
}

class TOTPPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _TOTPPageState createState() => _TOTPPageState();
}

class _TOTPPageState extends State<TOTPPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  List<Map<String, String>> _keys = []; // [{name, key}]
  String? _selectedKey;
  String _totpCode = '';
  int _remainingSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadKeys();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      setState(() {
        _remainingSeconds = 30 - (now % 30);
        if (_selectedKey != null) {
          _totpCode = _generateTOTP(_selectedKey!);
        }
      });
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _loadKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('totp_keys');
    if (jsonString != null) {
      setState(() {
        _keys = List<Map<String, String>>.from(
            jsonDecode(jsonString).map((x) => Map<String, String>.from(x)));
      });
    }
  }

  Future<void> _addKey() async {
    if (_nameController.text.isEmpty || _keyController.text.isEmpty) {
      _showError('decs & key can not be empty');
      return;
    }

    try {
      CustomBase32.decode(_keyController.text);
    } on FormatException {
      _showError('bad base32 key');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _keys.add({'name': _nameController.text, 'key': _keyController.text});
      prefs.setString('totp_keys', jsonEncode(_keys));
      _nameController.clear();
      _keyController.clear();
    });
  }

  Future<void> _deleteKey() async {
    if (_selectedKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _keys.removeWhere((item) => item['key'] == _selectedKey);
      prefs.setString('totp_keys', jsonEncode(_keys));
      _selectedKey = null;
      _totpCode = '';
    });
  }

  String _generateTOTP(String secret) {
    try {
      final key = CustomBase32.decode(secret);

      final time = (DateTime.now().millisecondsSinceEpoch ~/ 1000) ~/ 30;
      final msg = _longToBytes(time);

      final hmac = Hmac(sha1, key);
      final digest = hmac.convert(msg);

      final offset = digest.bytes[digest.bytes.length - 1] & 0x0F;
      final code = ((digest.bytes[offset] & 0x7F) << 24 |
              (digest.bytes[offset + 1] & 0xFF) << 16 |
              (digest.bytes[offset + 2] & 0xFF) << 8 |
              (digest.bytes[offset + 3] & 0xFF)) %
          1000000;

      return code.toString().padLeft(6, '0');
    } on FormatException catch (e) {
      return "bad res: ${e.message}";
    }
  }

  List<int> _longToBytes(int num) {
    return [
      (num >> 56) & 0xFF,
      (num >> 48) & 0xFF,
      (num >> 40) & 0xFF,
      (num >> 32) & 0xFF,
      (num >> 24) & 0xFF,
      (num >> 16) & 0xFF,
      (num >> 8) & 0xFF,
      num & 0xFF,
    ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TOTP Generator')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'desc',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keyController,
                    decoration: InputDecoration(
                        labelText: 'Base32 key',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                            icon: Icon(Icons.info),
                            onPressed: () => showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      title: Text('Need'),
                                      content: Text('Base32 Str'),
                                    )))),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addKey,
                  child: Text('Add'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedKey,
                    hint: Text('Select'),
                    items: _keys.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem<String>(
                        value: item['key'],
                        child: Text('${item['name']}'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => _selectedKey = newValue);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.panorama_fish_eye),
                  onPressed: _selectedKey != null
                      ? () {
                          showDialog(
                            context: context, 
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Key'),
                                content: Text('$_selectedKey'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: _selectedKey != null ? _deleteKey : null,
                )
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(_totpCode.isEmpty ? 'Please Select Key' : _totpCode,
                      style: TextStyle(fontSize: 24)),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _remainingSeconds / 30,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text('deadline: $_remainingSeconds s'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
