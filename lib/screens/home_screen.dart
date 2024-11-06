import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('add vehicule'),
              onTap: () {
                Navigator.pushNamed(context, '/addVehicule');
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('add driver'),
              onTap: () {
                Navigator.pushNamed(context, '/addDriver');
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Vehicules'),
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
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('map'),
              onTap: () {
                Navigator.pushNamed(context, '/Map');
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Weather'),
              onTap: () {
                Navigator.pushNamed(context, '/Weather');
              },
            ),
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
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/booking');
              },
              child: const Text('Book a Taxi'),
            ),
          ],
        ),
      ),
    );
  }
}
