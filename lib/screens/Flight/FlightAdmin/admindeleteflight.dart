import 'package:flutter/material.dart';
import '../../../services/FlightFirebase/firebase_service.dart';


class DeleteFlightScreen extends StatelessWidget {
  final String flightId;
  final FirebaseService _firebaseService = FirebaseService();

  // Remove `const` from constructor
   DeleteFlightScreen({Key? key, required this.flightId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Flight')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Are you sure you want to delete this flight?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _firebaseService.deleteFlight(flightId);
                Navigator.pop(context);
              },
              child: const Text('Confirm Delete'),
              // Use backgroundColor instead of primary
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

