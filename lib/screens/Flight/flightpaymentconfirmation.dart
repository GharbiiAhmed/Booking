import 'package:flutter/material.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final Map<String, String> bookingDetails;

  PaymentConfirmationScreen({required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    // Get values with a fallback of 'N/A' if the value is null
    String flightNumber = bookingDetails['flightNumber'] ?? 'N/A';
    String departure = bookingDetails['departure'] ?? 'N/A';
    String arrival = bookingDetails['arrival'] ?? 'N/A';
    String price = bookingDetails['price'] ?? 'N/A';
    String name = bookingDetails['name'] ?? 'N/A';
    String passport = bookingDetails['passport'] ?? 'N/A';
    String seat = bookingDetails['seat'] ?? 'N/A';

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
            Text('Flight Number: $flightNumber'),
            Text('Departure: $departure'),
            Text('Arrival: $arrival'),
            Text('Price: $price'),
            SizedBox(height: 20),
            Text('Passenger Details:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Name: $name'),
            Text('Passport: $passport'),
            Text('Seat: $seat'),
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
