import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/User.dart';
import '../../models/reservation.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({Key? key}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  late Future<List<Reservation>> reservationFuture;

  @override
  void initState() {
    super.initState();
    reservationFuture = fetchReservationsByUser();
  }

  Future<void> _generatePDF(Reservation reservation) async {
    try {
      final userName = await _fetchUserName(reservation.userId);
      final hotelName = await _fetchHotelName(reservation.hotelId);

      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Hotel Reservation Details',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Reservation ID:', reservation.id],
                  ['User Name:', userName],
                  ['Hotel Name:', hotelName],
                  ['Start Date:', formatDateTime(reservation.startDate)],
                  ['End Date:', formatDateTime(reservation.endDate)],
                  ['Number of Rooms:', reservation.numberOfRooms.toString()],
                  ['Adults:', reservation.adults.toString()],
                  ['Kids:', reservation.kids.toString()],
                  ['Total Amount:', '\$${reservation.total.toStringAsFixed(2)}'],
                ],
                cellAlignment: pw.Alignment.centerLeft,
                headerStyle: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
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
                child: pw.Text(
                  'Generated on ${DateTime.now().toLocal()}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ));

      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        String filePath = p.join(directory.path, 'hotel_reservation_${reservation.id}.pdf');
        final file = File(filePath);

        await file.writeAsBytes(await pdf.save());
        print("PDF saved at ${file.path}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to: ${file.path}')),
        );
      } else {
        print('Failed to get external storage directory.');
      }

    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

// Utility functions
  String formatDateTime(DateTime dateTime) {
    return '${dateTime.toLocal().toString().split(' ')[0]}'; // Format as YYYY-MM-DD
  }

  Future<String> _fetchUserName(String userId) async {
    // Fetch user data from Firestore
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    return userDoc.exists ? userDoc['name'] as String : 'Unknown User';
  }

  Future<String> _fetchHotelName(String hotelId) async {
    // Fetch hotel data from Firestore
    DocumentSnapshot hotelDoc =
    await FirebaseFirestore.instance.collection('hotels').doc(hotelId).get();
    return hotelDoc.exists ? hotelDoc['titleTxt'] as String : 'Unknown Hotel';
  }



  Future<List<Reservation>> fetchReservationsByUser() async {
    String userId = User.getInstance().userId;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return [];
    } else {
      return querySnapshot.docs.map((doc) {
        return Reservation.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    }
  }

  Future<void> cancelReservation(String reservationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation canceled successfully')),
      );
      setState(() {
        reservationFuture = fetchReservationsByUser(); // Refresh the list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error canceling reservation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reservation Details')),
      body: FutureBuilder<List<Reservation>>(
        future: reservationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reservation found.'));
          } else {
            List<Reservation> reservations = snapshot.data!;

            return ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                Reservation reservation = reservations[index];

                return Card(
                  margin: const EdgeInsets.all(12.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hotel ID: ${reservation.hotelId}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Start Date: ${reservation.startDate.toLocal()}', style: TextStyle(fontSize: 16)),
                        Text('End Date: ${reservation.endDate.toLocal()}', style: TextStyle(fontSize: 16)),
                        Text('Rooms: ${reservation.numberOfRooms}', style: TextStyle(fontSize: 16)),
                        Text('Adults: ${reservation.adults}', style: TextStyle(fontSize: 16)),
                        Text('Kids: ${reservation.kids}', style: TextStyle(fontSize: 16)),
                        Text('Total: \$${reservation.total.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _generatePDF(reservation);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Generate PDF'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showCancelDialog(reservation.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Cancel Reservation'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

              },
            );
          }
        },
      ),
    );
  }

  void _showCancelDialog(String reservationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Reservation'),
          content: Text('Are you sure you want to cancel this reservation?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await cancelReservation(reservationId);
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
