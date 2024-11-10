import 'package:flight_reservation/screens/Flight/flightseatselection.dart';
import 'package:flight_reservation/services/FlightFirebase/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // For user authentication

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
  final FirebaseService _firebaseService = FirebaseService(); // Initialize FirebaseService
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // Debugging: Print the flightDetails to confirm the data
    print("BookingScreen - Flight Details: ${widget.flightDetails}");

    // Ensure that origin and destination fields are not null and are being passed correctly
    String origin = widget.flightDetails['origin'] ?? 'Origin not available';
    String destination = widget.flightDetails['destination'] ?? 'Destination not available';
    String price = widget.flightDetails['price'] != null ? '\$${widget.flightDetails['price']}' : 'Price not available';

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Flight'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Image
            Center(
              child: Image.asset(
                'assets/images/booking.png', // Path to your booking.png image
                height: 150,
                width: 250,
              ),
            ),
            SizedBox(height: 20),

            // Flight Details
            Text(
              'Flight ${widget.flightDetails['flightNumber'] ?? 'N/A'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Origin: $origin - Destination: $destination',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Price: $price',
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

            // Seat Selection
            Text('Selected Seat: ${selectedSeat ?? 'No seat selected'}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final selected = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SeatSelectionScreen()),
                );

                // Update selected seat if chosen
                if (selected != null) {
                  setState(() {
                    selectedSeat = selected;
                  });
                }
              },
              child: Text('Select Seat'),
            ),
            SizedBox(height: 20),

            // Proceed to Payment
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty || passportController.text.isEmpty || selectedSeat == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all fields and select a seat')),
                    );
                  } else {
                    // Save booking to Firestore before proceeding to payment
                    _saveBookingToFirestore();

                    // Navigate to payment screen with flight and booking details
                    Navigator.pushNamed(
                      context,
                      '/payment',
                      arguments: {
                        'flightNumber': widget.flightDetails['flightNumber'] ?? 'N/A',
                        'origin': origin,
                        'destination': destination,
                        'price': price,
                        'name': nameController.text,
                        'passport': passportController.text,
                        'seat': selectedSeat ?? 'No seat selected',
                        'tripType': widget.flightDetails['tripType'] ?? 'One Way',
                        'departureDate': widget.flightDetails['departureDate'],
                        'returnDate': widget.flightDetails['tripType'] == 'Round Trip' ? widget.flightDetails['returnDate'] : null,
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

  Future<void> _saveBookingToFirestore() async {
    try {
      // Get the current user ID from Firebase Authentication
      User? currentUser = _auth.currentUser;
      String userId = currentUser != null ? currentUser.uid : 'exampleUserId';  // Use the actual user ID

      // Prepare booking details for Firestore
      final bookingDetails = {
        'flightId': widget.flightDetails['id'], // Ensure flight ID is included in flight details
        'userId': userId, // Use actual user ID in production
        'tripType': widget.flightDetails['tripType'] ?? 'One Way',
        'departureDate': widget.flightDetails['departureDate'],
        'returnDate': widget.flightDetails['tripType'] == 'Round Trip' ? widget.flightDetails['returnDate'] : null,
        'name': nameController.text,
        'passport': passportController.text,
        'seat': selectedSeat ?? 'No seat selected',
        'createdAt': DateTime.now(),
      };

      // Save booking via FirebaseService
      await _firebaseService.saveBooking(
        flightId: widget.flightDetails['id'],  // Pass the correct flight ID
        userId: userId,  // Pass the actual user ID
        tripType: widget.flightDetails['tripType'] ?? 'One Way',
        departureDate: widget.flightDetails['departureDate'],
        returnDate: widget.flightDetails['tripType'] == 'Round Trip' ? widget.flightDetails['returnDate'] : null,
        name: nameController.text,
        passport: passportController.text,
        seat: selectedSeat ?? 'No seat selected',
      );

      // Show confirmation notification
      _showCoolNotification();
    } catch (e) {
      print('Error saving booking: $e');
      String errorMessage = 'An error occurred while saving your booking. Please try again.';
      if (e is FirebaseException) {
        errorMessage = 'Error saving booking to Firestore. Please check your connection.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  void _showCoolNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Thank you for your booking! Your flight is confirmed.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
