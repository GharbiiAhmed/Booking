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
    return DateFormat('dd-MM-yyyy – kk:mm').format(dateTime!);
  }

  Future<void> _generatePDF(Reservation reservation) async {
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
                ['Name:', _fetchUserName(reservation.userId) ],
                ['Driver Name:', _fetchDriverName(reservation.driverId)],
                ['Vehicle Plate Number:', _fetchVehiclePlate(reservation.vehicleId!) ?? 'N/A'],
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

          return Expanded(
            child: ListView.builder(
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
                      'Vehicle Plate Number: ${_fetchVehiclePlate(reservation.vehicleId!)}';
                  if (reservation.driverId.isNotEmpty) {
                    displayText += '\nDriver Name: ${_fetchDriverName(reservation.driverId)}';
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
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _cancelReservation(reservation.reservationId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _generatePDF(reservation),
                              child: const Icon(Icons.download),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
