import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/services.dart';

class BcryptPage extends StatefulWidget {
  @override
  _BcryptGeneratorPageState createState() => _BcryptGeneratorPageState();
}

class _BcryptGeneratorPageState extends State<BcryptPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _saltController = TextEditingController();
  String _result = '';
  String _errorMessage = '';

  void _generateBcrypt() {
  final text = _textController.text;
  if (text.isEmpty) {
    setState(() => _errorMessage = 'Content');
    return;
  }

  final saltRounds = int.tryParse(_saltController.text) ?? 10;
  final validSalt = BCrypt.gensalt(logRounds: saltRounds);
  
  final hashed = BCrypt.hashpw(text, validSalt);

  setState(() {
    _result = 'Hash Value:$hashed\n(Salt：$validSalt)';
    _errorMessage = '';
  });
}

  Future<void> _copyResult() async {
    if (_result.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copyed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bcrypt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                hintText: 'Content',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _saltController,
              decoration: InputDecoration(
                labelText: 'Round (Default 10)',
                hintText: 'Example: 10',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateBcrypt,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Go',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            if (_result.isNotEmpty)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _result,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.content_copy),
                        onPressed: _copyResult,
                        tooltip: 'Copy',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}