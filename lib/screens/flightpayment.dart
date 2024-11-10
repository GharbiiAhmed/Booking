import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
              'Flight Number: ${widget.flightDetails['flightNumber']}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Departure: ${widget.flightDetails['departure']}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Arrival: ${widget.flightDetails['arrival']}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Price: \$${widget.flightDetails['price']}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Name: ${widget.flightDetails['name']}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Passport: ${widget.flightDetails['passport']}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Selected Seat: ${widget.flightDetails['seat']}',
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
                onPressed: () {
                  if (cardNumberController.text.isEmpty ||
                      expirationDateController.text.isEmpty ||
                      cvvController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all card information')),
                    );
                  } else {
                    // Prepare payment details
                    Map<String, dynamic> paymentDetails = {
                      'flightNumber': widget.flightDetails['flightNumber'],
                      'name': widget.flightDetails['name'],
                      'passport': widget.flightDetails['passport'],
                      'seat': widget.flightDetails['seat'],
                      'price': widget.flightDetails['price'],
                      'cardNumber': cardNumberController.text,
                      'expirationDate': expirationDateController.text,
                      'cvv': cvvController.text,
                    };

                    // Show a notification before generating the PDF
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Processing Payment...')),
                    );

                    // Generate and download the PDF after payment
                    generateAndDownloadPDF(paymentDetails);
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

  Future<void> generateAndDownloadPDF(Map<String, dynamic> paymentDetails) async {
    try {
      final pdf = pw.Document();

      // Add a stylish header with a gradient background color
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with gradient background
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
                _buildTable([
                  ['Flight Number:', paymentDetails['flightNumber'] ?? 'N/A'],
                  ['Departure:', paymentDetails['departure'] ?? 'N/A'],
                  ['Arrival:', paymentDetails['arrival'] ?? 'N/A'],
                  ['Price:', '\$${paymentDetails['price'] ?? 'N/A'}'],
                  ['Name:', paymentDetails['name'] ?? 'N/A'],
                  ['Passport:', paymentDetails['passport'] ?? 'N/A'],
                  ['Selected Seat:', paymentDetails['seat'] ?? 'N/A'],
                ]),
                pw.SizedBox(height: 20),

                // Payment Details with different background color
                pw.Text(
                  "Payment Details",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.green),
                ),
                pw.Divider(),
                pw.SizedBox(height: 10),
                _buildTable([
                  ['Payment Method:', 'Credit Card'],
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

      // Convert the PDF document to bytes
      final Uint8List pdfBytes = await pdf.save();

      // Use the printing package to download the PDF
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
        return pdfBytes;
      });

    } catch (e) {
      print("Error generating PDF: $e");  // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  // Helper function to build a styled table
  pw.Widget _buildTable(List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black),
      children: data.map((row) {
        return pw.TableRow(
          children: [
            pw.Text(row[0], style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text(row[1], style: pw.TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}
