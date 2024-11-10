
import 'package:flutter/material.dart';
import '../../services/FlightFirebase/firebase_service.dart';

import 'adminupdateflight.dart';

class ReadFlightsScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  ReadFlightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flights')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firebaseService.readFlights(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final flights = snapshot.data;
          return ListView.builder(
            itemCount: flights?.length ?? 0,
            itemBuilder: (context, index) {
              final flight = flights![index];
              return ListTile(
                title: Text(flight['flightNumber']),
                subtitle: Text('Price: \$${flight['price']}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateFlightScreen(
                      flightId: flight['id'],
                      initialFlightData: flight,
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text('Are you sure you want to delete this flight?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      await _firebaseService.deleteFlight(flight['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Flight deleted successfully')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
