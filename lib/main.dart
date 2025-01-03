import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gymdiary/screens/home_page.dart';
import 'package:gymdiary/screens/settings_page.dart';
import 'package:gymdiary/providers/workoutTemplateProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymdiary/providers/workoutProvider.dart';
import 'package:gymdiary/providers/databaseHelper.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures the app is initialized before running

  // Request permissions before database initialization
  await requestPermissions();

  // Initialize the provider and database after permissions are granted
  final workoutTemplateProvider = WorkoutTemplateProvider();
  final workoutProvider = WorkoutProvider();
  final databaseHelper = DatabaseHelper();
  await databaseHelper.openDatabaseConnection();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => workoutTemplateProvider),
        ChangeNotifierProvider(create: (_) => workoutProvider),
      ],
      child: const MyApp(),
    ),
  );
}

// Function to request permissions
Future<void> requestPermissions() async {
  // Request manage external storage permission on Android 11+
  if (await Permission.manageExternalStorage.isPermanentlyDenied) {
    // Open app settings if the permission is permanently denied
    openAppSettings();
  } else {
    // Request permission for manage external storage
    var status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      // Permission granted
      print("Storage Permission Granted");
    } else {
      // Handle the case where permission is denied
      print("Storage Permission Denied");
    }
  }

  // Optionally, request additional permissions like read and write storage
  if (await Permission.storage.request().isGranted) {
    print("Storage Permission granted");
  } else {
    print("Storage Permission denied");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  // Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('languageCode') ?? 'en';
    setState(() {
      _locale = Locale(savedLanguage);
    });
  }

  // Change language and save to SharedPreferences
  Future<void> _changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() {
      _locale = locale;
    });
    debugPrint("Language changed to ${locale.languageCode}");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fi'),
      ],
      locale: _locale,
      home: MainPage(
        changeLanguage: _changeLanguage,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.changeLanguage});

  final Function(Locale) changeLanguage;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const WorkoutHomePage(),
    const SettingsPage(),
    const WorkoutHomePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      debugPrint("Selected index: $_selectedIndex");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.gymDiary),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<Locale>(
            onSelected: widget.changeLanguage,
            icon: const Icon(Icons.language),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<Locale>(
                  value: const Locale('en'),
                  child: Text(AppLocalizations.of(context)!.english),
                ),
                PopupMenuItem<Locale>(
                  value: const Locale('fi'),
                  child: Text(AppLocalizations.of(context)!.finnish),
                ),
              ];
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppLocalizations.of(context)!.homePage,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settingsPage,
          ),
        ],
      ),
    );
  }
}
