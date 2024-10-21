import 'package:flutter/material.dart';
import 'screens/flightpayment.dart';
import 'screens/flightsearch.dart';
import 'screens/flightresult.dart';
import 'screens/flightbooking.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Track the current theme mode
  ThemeMode _themeMode = ThemeMode.light;

  // Track the current index of the BottomNavigationBar
  int _currentIndex = 0;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
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
      initialRoute: '/search',
      routes: {
        '/search': (context) => FlightSearchScreen(onThemeToggle: _toggleTheme),
        // Add other routes if necessary
        // '/courses': (context) => CoursesScreen(), // Example route for courses
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
          final args = settings.arguments as Map<String, dynamic>; // Use dynamic here
          return MaterialPageRoute(
            builder: (context) => BookingScreen(flightDetails: args),
          );
        } else if (settings.name == '/payment') {
          final args = settings.arguments as Map<String, dynamic>; // Use dynamic here
          return MaterialPageRoute(
            builder: (context) => PaymentScreen(flightDetails: args),
          );
        }
        return null;
      },
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            FlightSearchScreen(onThemeToggle: _toggleTheme), // Home screen
            Container(color: Colors.red), // Placeholder for Courses screen
            Container(color: Colors.green), // Placeholder for Notifications screen
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Navigate to other screens when tapping
            if (index == 1) {
              // Navigate to the 'Courses' screen
              Navigator.pushNamed(context, '/search');
            }
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
        ),
      ),
    );
  }
}

