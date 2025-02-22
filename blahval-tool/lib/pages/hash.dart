import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:pointycastle/digests/ripemd160.dart';

class HashPage extends StatefulWidget {
  @override
  _HashCalculatorState createState() => _HashCalculatorState();
}

class _HashCalculatorState extends State<HashPage> {
  final TextEditingController _controller = TextEditingController();
  String _selectedEncoding = 'base16';
  Map<String, String> _hashResults = {};

  final List<String> _encodings = ['base2', 'base16', 'base64', 'base64url'];
  final List<String> _algorithms = [
    'md5',
    'sha1',
    'sha256',
    'sha224',
    'sha512',
    'sha384',
    'ripemd160'
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_calculateHashes);
  }

  String _encodeBytes(List<int> bytes) {
    switch (_selectedEncoding) {
      case 'base2':
        return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join();
      case 'base16':
        return _bytesToHex(bytes);
      case 'base64':
        return base64Encode(bytes);
      case 'base64url':
        return base64UrlEncode(bytes);
      default:
        return '';
    }
  }

String _bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  void _calculateHashes() {
    final text = _controller.text;
    if (text.isEmpty) {
      setState(() => _hashResults.clear());
      return;
    }

    final bytes = utf8.encode(text);
    final results = <String, String>{};

    results['md5'] = _encodeBytes(md5.convert(bytes).bytes);
    results['sha1'] = _encodeBytes(sha1.convert(bytes).bytes);
    results['sha256'] = _encodeBytes(sha256.convert(bytes).bytes);
    results['sha224'] = _encodeBytes(sha224.convert(bytes).bytes);
    results['sha512'] = _encodeBytes(sha512.convert(bytes).bytes);
    results['sha384'] = _encodeBytes(sha384.convert(bytes).bytes);

    final ripemd160 = RIPEMD160Digest();
    results['ripemd160'] = _encodeBytes(ripemd160.process(bytes));

    setState(() => _hashResults = results);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copyed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hash')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Str',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedEncoding,
              items: _encodings
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedEncoding = value!;
                _calculateHashes();
              }),
              decoration: InputDecoration(
                labelText: 'Digest encoding',
                border: OutlineInputBorder(),
              ),
            ),
            Expanded(
              child: ListView(
                children: _algorithms.map((algorithm) => Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            algorithm.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _hashResults[algorithm] ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.content_copy, size: 20),
                          onPressed: () => _copyToClipboard(_hashResults[algorithm] ?? ''),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}