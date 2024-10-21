import 'package:flutter/material.dart';
import 'flightresult.dart'; // Make sure to import the results screen
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

  // Sample data for best offer flights with images
  List<Map<String, dynamic>> bestOffers = [
    {
      'flightNumber': 'AA123',
      'price': 150,
      'duration': 120, // in minutes
      'layovers': 0,
      'airline': 'Airline A',
      'imagePath': 'assets/images/1.png', // Path to the image
    },
    {
      'flightNumber': 'BB456',
      'price': 300,
      'duration': 180,
      'layovers': 1,
      'airline': 'Airline B',
      'imagePath': 'assets/images/test.png',
    },
    {
      'flightNumber': 'CC789',
      'price': 200,
      'duration': 150,
      'layovers': 0,
      'airline': 'Airline C',
      'imagePath': 'assets/images/1.png',
    },
    {
      'flightNumber': 'DD012',
      'price': 250,
      'duration': 170,
      'layovers': 1,
      'airline': 'Airline D',
      'imagePath': 'assets/images/test.png',
    },
  ];

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
            // TextField for Origin with flight icon
            TextField(
              controller: originController,
              decoration: InputDecoration(
                labelText: 'Origin',
                hintText: 'Enter origin',
                prefixIcon: Icon(Icons.flight_takeoff), // Flight takeoff icon
              ),
            ),
            // TextField for Destination with flight icon
            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                labelText: 'Destination',
                hintText: 'Enter destination',
                prefixIcon: Icon(Icons.flight_land), // Flight landing icon
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
              child: ListView.builder(
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
                          Image.asset(
                            offer['imagePath'],
                            width: 120, // Set a fixed width for the image
                            height: 120, // Set a fixed height for the image
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Flight Number: ${offer['flightNumber']}',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Airline: ${offer['airline']}'),
                                Text('Price: \$${offer['price']}'),
                                Text('Duration: ${offer['duration']} minutes'),
                                Text('Layovers: ${offer['layovers']}'),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

