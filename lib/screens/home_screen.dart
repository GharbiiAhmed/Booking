import 'package:flutter/material.dart';

import '../models/User.dart';

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // Show these only if the user is an admin
            if (user.role == 'client') ...[
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Ride History'),
                onTap: () {
                  Navigator.pushNamed(context, '/history');
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Ongoing Reservations'),
                onTap: () {
                  Navigator.pushNamed(context, '/ongoing');
                },
              ),
            ],
            // Show these for all users
            if (user.role == 'admin') ...[
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Add Vehicle'),
                onTap: () {
                  Navigator.pushNamed(context, '/addVehicule');
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Add Driver'),
                onTap: () {
                  Navigator.pushNamed(context, '/addDriver');
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Vehicles'),
                onTap: () {
                  Navigator.pushNamed(context, '/AllVehicules');
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Drivers'),
                onTap: () {
                  Navigator.pushNamed(context, '/AllDrivers');
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Exit'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('User Info:'),
                Text('name: ${user.name}'),
              ],
            ),
            // Show 'Book a Taxi' only if the user is a non-admin
            if (user.role == 'client') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/booking');
                },
                child: const Text('Book a Taxi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
