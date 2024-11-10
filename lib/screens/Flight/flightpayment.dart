import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/FlightFirebase/firebase_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> flightDetails;

  PaymentScreen({required this.flightDetails});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Fetch data from flightDetails
    var flightDetails = widget.flightDetails;

    // Ensure proper fallback if data is missing
    String departure = flightDetails['departureDate'] ?? 'N/A';
    String arrival = flightDetails['returnDate'] ?? 'N/A';
    String tripType = flightDetails['tripType'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flight Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Flight Number: ${flightDetails['flightNumber']}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Departure: $departure',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Arrival: $arrival',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Trip Type: $tripType',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Price: \$${flightDetails['price']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),

            // Card Information Section
            Text(
              'Card Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: 'Enter your card number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: expirationDateController,
              decoration: InputDecoration(
                labelText: 'Expiration Date (MM/YY)',
                hintText: 'Enter expiration date',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 10),
            TextField(
              controller: cvvController,
              decoration: InputDecoration(
                labelText: 'CVV',
                hintText: 'Enter CVV',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            // Confirm Payment Button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (cardNumberController.text.isEmpty ||
                      expirationDateController.text.isEmpty ||
                      cvvController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all card information')),
                    );
                  } else {
                    // Prepare payment details
                    Map<String, dynamic> paymentDetails = {
                      'flightNumber': flightDetails['flightNumber'],
                      'price': flightDetails['price'],
                      'cardNumber': cardNumberController.text,
                      'expirationDate': expirationDateController.text,
                      'cvv': cvvController.text,
                      'tripType': tripType,  // Added tripType to paymentDetails
                      'departure': departure,
                      'arrival': arrival,  // Added arrival field
                    };

                    // Show a notification before processing the payment
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Processing Payment...')),
                    );

                    // Save payment to Firestore
                    await savePayment(
                      userId: 'user123',  // Example userId, replace with actual user
                      flightId: flightDetails['flightNumber'], // Use flight number as flightId
                      price: double.tryParse(flightDetails['price'].toString()) ?? 0.0,  // Convert price to double
                      paymentMethod: 'Credit Card',  // Hardcoded for now
                      paymentStatus: 'Success',  // Assuming payment was successful
                      tripType: tripType,
                      departure: departure,
                      arrival: arrival,
                    );

                    // Show Payment Successful message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment Successful!')),
                    );

                    // Navigate back to the Flight Search screen
                    Navigator.popUntil(context, (route) => route.isFirst);


                    // Use a delay before opening the PDF to ensure the screen transition happens
                    await Future.delayed(Duration(milliseconds: 500));

                    // Generate and download the PDF after payment
                    await generateAndDownloadPDF(paymentDetails);
                  }
                },
                child: Text('Confirm Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> savePayment({
    required String userId,
    required String flightId,
    required double price,
    required String paymentMethod,
    required String paymentStatus,
    required String tripType,
    required String departure, // Origin
    required String arrival, // Destination
  }) async {
    try {
      final paymentData = {
        'userId': userId,
        'flightId': flightId,
        'price': price,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'tripType': tripType,
        'departure': departure, // Saving departure as origin
        'arrival': arrival, // Saving arrival as destination
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save data to Firestore in the 'payments' collection
      await FirebaseFirestore.instance.collection('payments').add(paymentData);
    } catch (e) {
      print("Error saving payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving payment: $e')),
      );
    }
  }

  Future<void> generateAndDownloadPDF(Map<String, dynamic> paymentDetails) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  color: PdfColors.blue,
                  child: pw.Padding(
                    padding: pw.EdgeInsets.all(10),
                    child: pw.Text(
                      'Booking Receipt',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Flight Details with border and background
                pw.Text(
                  "Flight Details",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
                ),
                pw.Divider(),
                pw.SizedBox(height: 10),
                _buildTable([['Flight Number:', paymentDetails['flightNumber'] ?? 'N/A'],
                  ['Departure:', paymentDetails['departure'] ?? 'N/A'],
                  ['Arrival:', paymentDetails['arrival'] ?? 'N/A'],
                  ['Trip Type:', paymentDetails['tripType'] ?? 'N/A'],
                  ['Price:', '\$${paymentDetails['price'] ?? 'N/A'}'],
                ]),

                pw.SizedBox(height: 20),

                // Payment Details with different background color
                pw.Text(
                  "Payment Details",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.green),
                ),
                pw.Divider(),
                pw.SizedBox(height: 10),
                _buildTable([['Payment Method:', 'Credit Card'],
                  ['Amount Paid:', '\$${paymentDetails['price'] ?? 'N/A'}'],
                  ['Card Number:', paymentDetails['cardNumber'] ?? 'N/A'],
                  ['Expiration Date:', paymentDetails['expirationDate'] ?? 'N/A'],
                ]),

                pw.SizedBox(height: 20),

                // Footer message
                pw.Center(
                  child: pw.Text(
                    'Thank you for booking with us!',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.grey),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Convert to PDF bytes and print the PDF
      final pdfBytes = await pdf.save();
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
    } catch (e) {
      print("Error generating PDF: $e");
    }
  }

  pw.Table _buildTable(List<List<String>> data) {
    return pw.Table.fromTextArray(
      headers: ['Field', 'Value'],
      data: data,
      border: pw.TableBorder.all(),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }
}
