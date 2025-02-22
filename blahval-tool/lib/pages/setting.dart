import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blahval/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.setting)),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.theme,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 100,
                  child: DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    isExpanded: true,
                    alignment: Alignment.centerRight,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('System'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('Light'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('Black'),
                        ),
                      ),
                    ],
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        themeProvider.setTheme(value);
                      }
                    },
                    underline: Container(height: 0),
                    icon: const Icon(Icons.arrow_drop_down, size: 24),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
