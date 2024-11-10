import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taxi_reservation/models/Reservation.dart';
import 'package:pdf/widgets.dart' as pw;


class OngoingReservationsScreen extends StatefulWidget {
  const OngoingReservationsScreen({super.key});

  @override
  _OngoingReservationsScreenState createState() => _OngoingReservationsScreenState();
}

class _OngoingReservationsScreenState extends State<OngoingReservationsScreen> {
  final String userId = '1';

  Future<String> _fetchDriverName(String driverId) async {
    try {
      final driverDoc = await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(driverId)
          .get();

      if (driverDoc.exists) {
        return driverDoc['name'] ?? 'Unknown Driver';
      } else {
        return 'Driver not found';
      }
    } catch (e) {
      print('Error fetching driver: $e');
      return 'Error fetching driver';
    }
  }

  Future<String> _fetchVehiclePlate(String vehicleId) async {
    try {
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('Vehicles')
          .doc(vehicleId)
          .get();

      if (vehicleDoc.exists) {
        return vehicleDoc['plateNumber'] ?? 'Unknown Plate';
      } else {
        return 'Vehicle not found';
      }
    } catch (e) {
      print('Error fetching vehicle: $e');
      return 'Error fetching vehicle';
    }
  }

  Future<String> _fetchUserName(String userId) async {
    try {
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (vehicleDoc.exists) {
        return vehicleDoc['plateNumber'] ?? 'Unknown User';
      } else {
        return 'user not found';
      }
    } catch (e) {
      print('Error fetching user: $e');
      return 'Error fetching user';
    }
  }

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

          // Success pop-up dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Reservation canceled successfully.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Reservation not found pop-up dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Reservation not found.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        print("Error: $e");

        // Failed to cancel reservation pop-up dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to cancel reservation.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  String formatDateTime(DateTime? dateTime) {
    return DateFormat('dd-MM-yyyy – kk:mm').format(dateTime!);
  }

  Future<void> _generatePDF(Reservation reservation) async {
    // Fetch necessary data
    final driverName = await _fetchDriverName(reservation.driverId);
    final vehiclePlate = await _fetchVehiclePlate(reservation.vehicleId!);
    final userName = await _fetchUserName(userId);

    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text('Reservation Details',
                  style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue)),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              data: [
                ['Reservation ID:', reservation.reservationId],
                ['Name:', userName],
                ['Driver Name:', driverName],
                ['Vehicle Plate Number:', vehiclePlate],
                ['Type:', reservation.type],
                ['Pickup Location:', reservation.pickupLocation ?? 'N/A'],
                ['Dropoff Location:', reservation.dropoffLocation ?? 'N/A'],
                ['Reservation Date:', formatDateTime(reservation.reservationDate)],
                if (reservation.startDate != null)
                  ['Start Date:', formatDateTime(reservation.startDate)],
                if (reservation.endDate != null)
                  ['End Date:', formatDateTime(reservation.endDate)],
              ],
              cellAlignment: pw.Alignment.centerLeft,
              headerStyle: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.blueGrey,
              ),
              cellStyle: pw.TextStyle(fontSize: 12),
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
              cellPadding: pw.EdgeInsets.all(5),
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Text('Generated on ${DateTime.now().toLocal()}',
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey)),
            ),
          ],
        );
      },
    ));

    Directory? directory;

    directory = await getDownloadsDirectory();
    if (directory != null) {
      String filePath = p.join(directory.path, 'reservation_${reservation.reservationId}.pdf');
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());
      print("PDF saved at ${file.path}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF downloaded to: ${file.path}')),
      );
    }
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

              // Future for driver name
              final driverNameFuture = reservation.driverId.isNotEmpty
                  ? _fetchDriverName(reservation.driverId)
                  : Future.value('No driver assigned');

              // Future for vehicle plate
              final vehiclePlateFuture = reservation.vehicleId != null
                  ? _fetchVehiclePlate(reservation.vehicleId!)
                  : Future.value('No vehicle assigned');

              return Column(
                children: [
                  FutureBuilder<String>(
                    future: driverNameFuture,
                    builder: (context, driverSnapshot) {
                      if (driverSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!driverSnapshot.hasData) {
                        return const Text('Error loading driver.');
                      }

                      final driverName = driverSnapshot.data!;

                      // FutureBuilder for vehicle plate
                      return FutureBuilder<String>(
                        future: vehiclePlateFuture,
                        builder: (context, vehicleSnapshot) {
                          if (vehicleSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (!vehicleSnapshot.hasData) {
                            return const Text('Error loading vehicle.');
                          }

                          final vehiclePlate = vehicleSnapshot.data!;

                          if (reservation.type == 'Taxi') {
                            displayText = 'From: ${reservation.pickupLocation} to: ${reservation.dropoffLocation} \n'
                                'Reservation Time: ${formatDateTime(reservation.reservationDate)}';
                          } else if (reservation.type == 'Personal Vehicle') {
                            displayText = 'Reservation Time: ${formatDateTime(reservation.reservationDate)} \n'
                                'Start Time: ${formatDateTime(reservation.startDate)} \n'
                                'End Time: ${formatDateTime(reservation.endDate)} \n'
                                'Vehicle Plate Number: ${vehiclePlate}';
                            if (reservation.driverId.isNotEmpty) {
                              displayText += '\nDriver Name: ${driverName}';
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.local_taxi, color: Colors.blueAccent),
                                    title: Text(
                                      'Reservation ${reservation.reservationId}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(displayText),
                                  ),
                                  const SizedBox(height: 8), // Space between card content and buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _cancelReservation(reservation.reservationId),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => _generatePDF(reservation),
                                        child: const Icon(Icons.download),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }


}
