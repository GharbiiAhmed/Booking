import 'package:flight_reservation/screens/flightseatselection.dart';
import 'package:flight_reservation/screens/flightpayment.dart'; // Make sure this is imported
import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> flightDetails;

  BookingScreen({required this.flightDetails});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passportController = TextEditingController();
  String? selectedSeat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Flight'),
      ),
      body: SingleChildScrollView( // Added to make the screen scrollable if needed
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add the booking.png picture at the top
            Center(
              child: Image.asset(
                'assets/images/booking.png', // Path to your booking.png image
                height: 150, // Adjust the height as needed
                width: 250,  // Adjust the width as needed
              ),
            ),
            SizedBox(height: 20),

            // Display Flight Details
            Text(
              'Flight ${widget.flightDetails['flightNumber'] ?? 'N/A'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Departure: ${widget.flightDetails['departure'] ?? 'N/A'} - Arrival: ${widget.flightDetails['arrival'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Price: \$${widget.flightDetails['price']?.toString() ?? 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Passenger Details
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passportController,
              decoration: InputDecoration(
                labelText: 'Passport Number',
                hintText: 'Enter your passport number',
              ),
            ),
            SizedBox(height: 20),

            // Seat Selection Button
            Text('Selected Seat: ${selectedSeat ?? 'No seat selected'}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final selected = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SeatSelectionScreen()),
                );

                // Update the selected seat if a seat was chosen
                if (selected != null) {
                  setState(() {
                    selectedSeat = selected; // Update selected seat
                  });
                }
              },
              child: Text('Select Seat'),
            ),
            SizedBox(height: 20),

            // Proceed to Payment Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty || passportController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all fields')),
                    );
                  } else {
                    // Navigate to payment screen with flight details and booking information
                    Navigator.pushNamed(
                      context,
                      '/payment',
                      arguments: {
                        'flightNumber': widget.flightDetails['flightNumber'] ?? 'N/A',
                        'departure': widget.flightDetails['departure'] ?? 'N/A',
                        'arrival': widget.flightDetails['arrival'] ?? 'N/A',
                        'price': widget.flightDetails['price']?.toString() ?? 'N/A',
                        'name': nameController.text,
                        'passport': passportController.text,
                        'seat': selectedSeat ?? 'No seat selected', // Ensure seat is not null
                      },
                    );
                  }
                },
                child: Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


