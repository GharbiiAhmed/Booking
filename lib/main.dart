import 'package:flight_reservation/FlightAdmin/admindashboard.dart';
import 'package:flight_reservation/FlightAdmin/userdashboard.dart';
import 'package:flight_reservation/screens/Flight/flightbooking.dart';
import 'package:flight_reservation/screens/Flight/flightpayment.dart';
import 'package:flight_reservation/screens/Flight/flightresult.dart';
import 'package:flight_reservation/screens/Flight/flightsearch.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'class/AppLocalizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permissions for iOS devices
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  int _currentIndex = 0;
  String _mode = 'home';

  // Notification plugin initialization
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _setupFirebaseListeners();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _setupFirebaseListeners() {
    // Handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotification(message);
      }
    });

    // Handling background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new message was opened from the background: ${message.data}');
      // Handle navigation based on the message data
    });

    // Handling when the app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('Notification caused app to open: ${message.data}');
      }
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data['payload'], // Optional: include payload data
    );
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _setMode(String mode) {
    setState(() {
      _mode = mode;
      _currentIndex = 0;
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flight App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
        Locale('fr', 'FR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppLocalizations.delegate, // Use the AppLocalizations delegate
      ],
      initialRoute: '/search',
      routes: {
        '/search': (context) => FlightSearchScreen(onThemeToggle: _toggleTheme),
        '/details': (context) => FlightDetailsScreen(), // New route for FlightDetailsScreen
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/results') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FlightResultsScreen(
              tripType: args['tripType'],
              origin: args['origin'],
              destination: args['destination'],
              departureDate: args['departureDate'],
              returnDate: args['returnDate'],
            ),
          );
        } else if (settings.name == '/booking') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => BookingScreen(flightDetails: args),
          );
        } else if (settings.name == '/payment') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PaymentScreen(flightDetails: args),
          );
        }
        return null;
      },
      home: Scaffold(
        appBar: AppBar(title: Text(_mode == 'admin' ? 'Admin Dashboard' : _mode == 'user' ? 'User Dashboard' : 'Flight App')),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'Flight App',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () => _setMode('home'),
              ),
              ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text('Admin Mode'),
                onTap: () => _setMode('admin'),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('User Mode'),
                onTap: () => _setMode('user'),
              ),
            ],
          ),
        ),
        body: _mode == 'admin'
            ? AdminDashboard()
            : _mode == 'user'
            ? UserDashboard()
            : IndexedStack(
          index: _currentIndex,
          children: [
            FlightSearchScreen(onThemeToggle: _toggleTheme),
            Container(color: Colors.red),
            Container(color: Colors.green),
          ],
        ),
        bottomNavigationBar: _mode == 'home'
            ? BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.flight),
              label: 'Flight',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hotel),
              label: 'Hotel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.car_rental),
              label: 'Car Rental',
            ),
          ],
        )
            : null,
      ),
    );
  }
}

// New Widget for Flight Details Screen
class FlightDetailsScreen extends StatelessWidget {
  const FlightDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flight Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Flight Details will be shown here.'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/booking', arguments: {'flightId': 123}); // Example argument
              },
              child: const Text('Book Flight'),
            ),
          ],
        ),
      ),
    );
  }
}