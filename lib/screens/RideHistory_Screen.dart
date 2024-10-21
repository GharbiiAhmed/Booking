import 'package:flutter/material.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.local_taxi),
              title: const Text('Pick-up: Central Park'),
              subtitle: const Text('Drop-off: Times Square'),
              trailing: const Text('Completed'),
            ),
            ListTile(
              leading: const Icon(Icons.local_taxi),
              title: const Text('Pick-up: 5th Avenue'),
              subtitle: const Text('Drop-off: Empire State'),
              trailing: const Text('Completed'),
            ),
            // Add more list items for real data
          ],
        ),
      ),
    );
  }
}
