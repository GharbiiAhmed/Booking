import 'package:flutter/material.dart';

import '../../models/User.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taxi Reservation'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Taxi Reservation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Show 'Book a Taxi' only if the user is a non-admin
            if (user.role == 'client') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/booking');
                },
                child: const Text('Book a Taxi'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: const Text('Ride History'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/ongoing');
                },
                child: const Text('On going reservation'),
              ),
            ],
            if (user.role == 'admin') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addVehicule');
                },
                child: const Text('Book a Taxi'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addDriver');
                },
                child: const Text('Ride History'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/AllVehicules');
                },
                child: const Text('On going reservation'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/AllDrivers');
                },
                child: const Text('On going reservation'),
              ),
            ],

          ],
        ),
      ),
    );
  }
}
