import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/setting.dart';
import 'pages/about.dart';
import 'pages/help.dart';
import 'pages/totp.dart';
import 'pages/token_gen.dart';
import 'pages/hash.dart';
import 'pages/calculator.dart';
import 'pages/screen_check.dart';
import 'pages/qr.dart';
import 'pages/base64.dart';
import 'pages/bcrypt.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('zh'),
      ],
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      home: HomeScreen(),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  static const String _prefsKey = 'theme_mode';

  ThemeMode get themeMode => _themeMode;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_prefsKey) ?? 'system';
    _themeMode = _parseThemeMode(mode);
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _modeToString(mode));
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _modeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}

class HomeScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [HomePage(), ProfilePage()];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("blahval", style: const TextStyle(fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: _buildSideMenu(),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildSideMenu() {
    return Drawer(
      width: 280,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blueAccent),
            child: Text(AppLocalizations.of(context)!.menu,
                style: const TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)!.setting),
            onTap: () => _handleMenuTap(0),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text(AppLocalizations.of(context)!.help),
            onTap: () => _handleMenuTap(1),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context)!.about),
            onTap: () => _handleMenuTap(2),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: Colors.blue[700],
      unselectedItemColor: Colors.grey[600],
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppLocalizations.of(context)!.main,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: AppLocalizations.of(context)!.my,
        ),
      ],
      onTap: (index) => setState(() => _currentIndex = index),
    );
  }

  void _handleMenuTap(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HelpPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutPage()),
        );
        break;
    }
  }
}

class MainMenu {
  final String title;
  final IconData icon;
  final List<SubMenu> subMenus;

  MainMenu({
    required this.title,
    required this.icon,
    required this.subMenus,
  });
}

class SubMenu {
  final String title;
  final Widget page;

  SubMenu({
    required this.title,
    required this.page,
  });
}

class HomePage extends StatelessWidget {
  List<MainMenu> _buildMenus(BuildContext context) {
    return [
      MainMenu(
        title: AppLocalizations.of(context)!.auth,
        icon: Icons.lock,
        subMenus: [
          SubMenu(
            title: 'totp',
            page: TOTPPage(),
          ),
        ]
      ),
      MainMenu(
        title: AppLocalizations.of(context)!.tools,
        icon: Icons.build,
        subMenus: [
          SubMenu(
            title: 'qr',
            page: QRPage(),
          ),
          SubMenu(
            title: 'calculator',
            page: CalculatorPage(),
          ),
          SubMenu(
            title: 'screen check',
            page: ScreenCheckPage(),
          ),
          
          SubMenu(
            title: 'token gen',
            page: TokenGenPage(),
          ),
        ]
      ),
      MainMenu(
        title: AppLocalizations.of(context)!.convert,
        icon: Icons.loop,
        subMenus: [
          SubMenu(
            title: 'hash',
            page: HashPage(),
          ),
          SubMenu(
            title: 'base64',
            page: Base64Page(),
          ),
          SubMenu(
            title: 'bcrypt',
            page: BcryptPage(),
          ),
        ]
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final menus = _buildMenus(context);
    return Scaffold(
      body: ListView.builder(
        itemCount: menus.length,
        itemBuilder: (context, index) {
          return _buildExpansionTile(context, menus[index]);
        },
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context, MainMenu menu) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        shape: Border(),
        leading: Icon(menu.icon),
        title: Text(menu.title, style: const TextStyle(fontSize: 16)),
        childrenPadding: const EdgeInsets.all(12),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: menu.subMenus.map((subMenu) {
              return _buildCapsuleButton(context, subMenu);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleButton(BuildContext context, SubMenu subMenu) {
    return GestureDetector(
      onTap: () => _navigateToPage(context, subMenu.page),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          subMenu.title,
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context)!.my));
  }
}
