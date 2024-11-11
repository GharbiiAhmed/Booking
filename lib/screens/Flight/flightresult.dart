import 'package:flutter/material.dart';
import 'package:taxi_reservation/screens/Flight/flightbooking.dart';
import '../../services/FlightFirebase/firebase_service.dart';

class FlightResultsScreen extends StatefulWidget {
  final String tripType;
  final String origin;
  final String destination;
  final DateTime departureDate;
  final DateTime? returnDate;

  FlightResultsScreen({
    required this.tripType,
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
  });

  @override
  _FlightResultsScreenState createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  final FirebaseService _firebaseService = FirebaseService(); // Initialize FirebaseService
  late Future<List<Map<String, dynamic>>> _flightResultsFuture; // Future to hold flight results
  bool showNotification = false; // Flag to show notification
  String notificationMessage = ''; // Notification message text

  @override
  void initState() {
    super.initState();
    // Fetch flight results from Firestore when the screen initializes
    _flightResultsFuture = _firebaseService.readFlightsByOriginAndDestination(
      origin: widget.origin,
      destination: widget.destination,
    );

    // After flight results are fetched, show a notification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flightResultsFuture.then((results) {
        if (results.isEmpty) {
          // Show 'no flights' notification if no results are found
          setState(() {
            showNotification = true;
            notificationMessage = 'Sorry, there are no available flights.';
          });

          // Auto-dismiss notification after 3 seconds
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              showNotification = false;
            });
          });
        } else {
          // Show 'flights found' notification if flights are found
          setState(() {
            showNotification = true;
            notificationMessage = 'Flights found!';
          });

          // Auto-dismiss notification after 3 seconds
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              showNotification = false;
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Results'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: showFilterDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Flight Results List
          FutureBuilder<List<Map<String, dynamic>>>(  // Fetch the flight results
            future: _flightResultsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No offers found.'));
              }

              // If we have data, display it
              final filteredResults = snapshot.data!; // Use the retrieved data
              return ListView.builder(
                itemCount: filteredResults.length,
                itemBuilder: (context, index) {
                  final flight = filteredResults[index];

                  // Null safety checks and fallback values
                  String flightImagePath = flight['imagePath'] ?? 'assets/default_image.png';
                  String flightNumber = flight['flightNumber'] ?? 'Unknown Flight Number';
                  String flightPrice = flight['price'] != null ? '\$${flight['price']}' : 'Price not available';
                  String tripType = widget.tripType; // Use the passed trip type

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: SizedBox(
                        width: 100, // Set the desired width of the leading widget
                        height: 100, // Set the desired height of the leading widget
                        child: Image.network(  // Use Image.network to load the image from URL
                          flightImagePath, // URL of the flight image
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(flightNumber), // Use fallback if flightNumber is null
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(flightPrice), // Use fallback if price is null
                          Text('Trip Type: $tripType'), // Display the trip type (One-Way or Round-Trip)
                        ],
                      ),
                      onTap: () {
                        // Pass flight details to the booking screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(
                              flight: flight,
                              flightDetails: flight, // Pass the whole flight object
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),

          // Notification Widget
          if (showNotification) _buildNotification(),
        ],
      ),
    );
  }

  // Widget to display notification in the center of the screen
  Widget _buildNotification() {
    return Center(
      child: Material(
        color: Colors.black.withOpacity(0.6), // Semi-transparent background
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification message
              Expanded(  // Use Expanded to prevent overflow
                child: Text(
                  notificationMessage,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,  // Ensure text doesn't overflow
                  softWrap: true,  // Allow the text to wrap
                ),
              ),
              // Close button
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    showNotification = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showFilterDialog() {
    // Show filter dialog implementation
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Example filter options (can add more if needed)
              DropdownButtonFormField<String>( // Price Range Filter
                decoration: InputDecoration(labelText: 'Price Range'),
                items: ['Under \$100', '\$100 - \$500', 'Above \$500']
                    .map((priceRange) {
                  return DropdownMenuItem<String>(
                    value: priceRange,
                    child: Text(priceRange),
                  );
                }).toList(),
                onChanged: (value) {
                  // Handle price range selection
                },
              ),
              DropdownButtonFormField<String>( // Duration Filter
                decoration: InputDecoration(labelText: 'Flight Duration'),
                items: ['Under 3 hours', '3-6 hours', 'Above 6 hours']
                    .map((duration) {
                  return DropdownMenuItem<String>(
                    value: duration,
                    child: Text(duration),
                  );
                }).toList(),
                onChanged: (value) {
                  // Handle flight duration selection
                },
              ),
              // Add additional filters here (e.g., layovers, airlines, etc.)
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Apply filters and refresh the data if necessary
                Navigator.of(context).pop();
                // You can trigger a state update to refetch flights with applied filters
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
