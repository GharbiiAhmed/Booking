import 'package:flutter/material.dart';
import '../services/firebase_service.dart'; // Import the Firebase service
import 'flightresult.dart'; // Import the results screen
import 'flightbooking.dart'; // Import the BookingScreen

class FlightSearchScreen extends StatefulWidget {
  final Function onThemeToggle;

  const FlightSearchScreen({Key? key, required this.onThemeToggle}) : super(key: key);

  @override
  _FlightSearchScreenState createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  String tripType = 'One-Way'; // Default trip type
  DateTime? departureDate;
  DateTime? returnDate;
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  Future<List<Map<String, dynamic>>>? bestOffersFuture; // Future for best offers

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          departureDate = picked;
        } else {
          returnDate = picked;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch best offers when the screen is initialized
    bestOffersFuture = _firebaseService.getBestOffers(maxPrice: 500, maxLayovers: 1); // Set your criteria

    // Show welcome dialog when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Welcome to Flight Booking!'),
          content: Text('We are glad to have you here. Start searching for your flights!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Search'),
        actions: [
          Switch(
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              widget.onThemeToggle(); // Call the toggle function from the parent widget
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Trip Type: '),
                Radio<String>(
                  value: 'One-Way',
                  groupValue: tripType,
                  onChanged: (value) {
                    setState(() {
                      tripType = value!;
                    });
                  },
                ),
                Text('One-Way'),
                Radio<String>(
                  value: 'Round-Trip',
                  groupValue: tripType,
                  onChanged: (value) {
                    setState(() {
                      tripType = value!;
                    });
                  },
                ),
                Text('Round-Trip'),
              ],
            ),
            TextField(
              controller: originController,
              decoration: InputDecoration(
                labelText: 'Origin',
                hintText: 'Enter origin',
                prefixIcon: Icon(Icons.flight_takeoff),
              ),
            ),
            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                labelText: 'Destination',
                hintText: 'Enter destination',
                prefixIcon: Icon(Icons.flight_land),
              ),
            ),
            Row(
              children: [
                Text('Departure: '),
                TextButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text(departureDate == null
                      ? 'Select date'
                      : '${departureDate!.toLocal()}'.split(' ')[0]),
                ),
              ],
            ),
            if (tripType == 'Round-Trip')
              Row(
                children: [
                  Text('Return: '),
                  TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(returnDate == null
                        ? 'Select date'
                        : '${returnDate!.toLocal()}'.split(' ')[0]),
                  ),
                ],
              ),
            Center(
              child: SizedBox(
                width: 500,
                child: ElevatedButton(
                  onPressed: () {
                    if (departureDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a departure date')),
                      );
                    } else {
                      // Navigate to results screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlightResultsScreen(
                            tripType: tripType,
                            origin: originController.text,
                            destination: destinationController.text,
                            departureDate: departureDate!,
                            returnDate: tripType == 'Round-Trip' ? returnDate : null,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('Search Flights'),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Best Offer Flights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>( // Fetch best offers
                future: bestOffersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No offers found.'));
                  }

                  final bestOffers = snapshot.data!;

                  return ListView.builder(
                    itemCount: bestOffers.length,
                    itemBuilder: (context, index) {
                      final offer = bestOffers[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              offer['imagePath'] != null && offer['imagePath'] != ''
                                  ? Image.network(
                                offer['imagePath'], // Cloudinary URL for the image
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[200], // Placeholder for missing image
                                child: Icon(Icons.image, color: Colors.grey),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offer['flightNumber'] ?? 'N/A',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(offer['airline'] ?? 'Unknown Airline'),
                                    Text('\$${offer['price'] ?? 'Unknown'}'),
                                    Text('Duration: ${offer['duration'] ?? 'Unknown'} minutes'),
                                    Text('Layovers: ${offer['layovers'] ?? 'None'}'),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BookingScreen(
                                              flightDetails: {
                                                'flightNumber': offer['flightNumber'],
                                                'airline': offer['airline'],
                                                'price': offer['price'],
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text('Book Now'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

