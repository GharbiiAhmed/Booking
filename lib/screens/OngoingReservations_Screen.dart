import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:taxi_reservation/models/Reservation.dart';

class OngoingReservationsScreen extends StatefulWidget {
  const OngoingReservationsScreen({super.key});

  @override
  _OngoingReservationsScreenState createState() => _OngoingReservationsScreenState();
}

class _OngoingReservationsScreenState extends State<OngoingReservationsScreen> {
  final String userId = '1';

  Future<void> _cancelReservation(String reservationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation'),
        content: const Text('Are you sure you want to cancel this reservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final docRef = FirebaseFirestore.instance.collection('reservations').doc(reservationId);
        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          await docRef.update({'state': 'Canceled'});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation canceled successfully.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation not found.')),
          );
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to cancel reservation.')),
        );
      }
    }
  }


  String formatDateTime(DateTime? dateTime) {
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Reservations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .where('userId', isEqualTo: userId)
            .where('state', isEqualTo: 'OnGoing')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No ongoing reservations.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final reservations = snapshot.data!.docs
              .map((doc) => Reservation.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              String displayText = '';

              if (reservation.type == 'Taxi') {
                displayText = 'From: ${reservation.pickupLocation} to: ${reservation.dropoffLocation} \n'
                    'Reservation Time: ${formatDateTime(reservation.reservationDate)}';
              } else if (reservation.type == 'Personal Vehicle') {
                displayText = 'Reservation Time: ${formatDateTime(reservation.reservationDate)} \n'
                    'Start Time: ${formatDateTime(reservation.startDate)} \n'
                    'End Time: ${formatDateTime(reservation.endDate)} \n'
                    'Vehicle Plate Number: ${reservation.vehicleId}';
                if (reservation.driverId.isNotEmpty) {
                  displayText += '\nDriver Name: ${reservation.driverId}';
                }
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.local_taxi, color: Colors.blueAccent),
                    title: Text(
                      'Reservation ${reservation.reservationId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(displayText),
                    trailing: ElevatedButton(
                      onPressed: () => _cancelReservation(reservation.reservationId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
