import 'package:flutter/material.dart';
import 'package:taxi_reservation/screens/Admin/AddVehicleScreen.dart';
import 'screens/home_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/ridehistory_screen.dart';
import 'screens/ongoingreservations_screen.dart';

void main() {
  runApp(const TaxiReservationApp());
}

class TaxiReservationApp extends StatelessWidget {
  const TaxiReservationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taxi Reservation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/booking': (context) => const BookingScreen(),
        '/confirmation': (context) => const ConfirmationScreen(),
        '/history': (context) => const RideHistoryScreen(),
        '/ongoing': (context) => const OngoingReservationsScreen(),
        '/addVehicule' : (context) => const AddVehicleScreen(),
      },
    );
  }
}
