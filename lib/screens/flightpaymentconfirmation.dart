import 'package:flutter/material.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final Map<String, String> bookingDetails;

  PaymentConfirmationScreen({required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Confirmation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Confirmed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Flight Details:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Flight Number: ${bookingDetails['flightNumber']}'),
            Text('Departure: ${bookingDetails['departure']}'),
            Text('Arrival: ${bookingDetails['arrival']}'),
            Text('Price: ${bookingDetails['price']}'),
            SizedBox(height: 20),
            Text('Passenger Details:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Name: ${bookingDetails['name']}'),
            Text('Passport: ${bookingDetails['passport']}'),
            Text('Seat: ${bookingDetails['seat']}'),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/search'));
                },
                child: Text('Back to Search'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
