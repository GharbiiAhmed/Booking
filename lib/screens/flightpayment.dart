import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> flightDetails; // Accept dynamic types for flexibility

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

            // Add the card.png picture before Card Information
            Center(
              child: Image.asset(
                'assets/images/card.png', // Path to your card.png image
                height: 100, // Adjust the height as needed
                width: 400,  // Adjust the width as needed
              ),
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
                  // Validate card information
                  if (cardNumberController.text.isEmpty ||
                      expirationDateController.text.isEmpty ||
                      cvvController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all card information')),
                    );
                  } else {
                    // Process the payment (you can add your payment logic here)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment Successful!')),
                    );
                    // Optionally navigate back or to a different screen
                    Navigator.popUntil(context, (route) => route.isFirst);
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
}


