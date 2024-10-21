import 'package:flutter/material.dart';

class OngoingReservationsScreen extends StatefulWidget {
  const OngoingReservationsScreen({super.key});

  @override
  _OngoingReservationsScreenState createState() => _OngoingReservationsScreenState();
}

class _OngoingReservationsScreenState extends State<OngoingReservationsScreen> {
  List<Map<String, String>> ongoingReservations = [
    {
      'pickup': 'Central Park',
      'dropoff': 'Times Square',
      'date': '2024-10-25',
      'time': '10:00 AM',
    },
    {
      'pickup': '5th Avenue',
      'dropoff': 'Empire State Building',
      'date': '2024-10-26',
      'time': '2:30 PM',
    },
  ];

  void _cancelReservation(int index) {
    setState(() {
      ongoingReservations.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reservation canceled successfully.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Reservations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ongoingReservations.isEmpty
            ? const Center(
          child: Text(
            'No ongoing reservations.',
            style: TextStyle(fontSize: 18),
          ),
        )
            : ListView.builder(
          itemCount: ongoingReservations.length,
          itemBuilder: (context, index) {
            final reservation = ongoingReservations[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.local_taxi),
                title: Text(
                  '${reservation['pickup']} to ${reservation['dropoff']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Date: ${reservation['date']} at ${reservation['time']}',
                ),
                trailing: ElevatedButton(
                  onPressed: () => _cancelReservation(index),
                  child: const Text('Cancel'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
