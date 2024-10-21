import 'package:flutter/material.dart';

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
  List<Map<String, dynamic>> flightResults = [
    {
      'flightNumber': 'AA123',
      'price': 150,
      'duration': 120, // in minutes
      'layovers': 0,
      'airline': 'Airline A',
      'baggageAllowance': 1, // in pieces
      'extraBaggageFee': 50,
      'imagePath': 'assets/images/test.png'// fee for additional baggage
    },
    {
      'flightNumber': 'BB456',
      'price': 300,
      'duration': 180, // in minutes
      'layovers': 1,
      'airline': 'Airline B',
      'baggageAllowance': 2, // in pieces
      'extraBaggageFee': 70, // fee for additional baggage
      'imagePath': 'assets/images/1.png'
    },
    {
      'flightNumber': 'CC789',
      'price': 200,
      'duration': 150, // in minutes
      'layovers': 0,
      'airline': 'Airline C',
      'baggageAllowance': 1, // in pieces
      'extraBaggageFee': 60, // fee for additional baggage
      'imagePath': 'assets/images/test.png'
    },
    {
      'flightNumber': 'DD012',
      'price': 250,
      'duration': 240, // in minutes
      'layovers': 2,
      'airline': 'Airline D',
      'baggageAllowance': 2, // in pieces
      'extraBaggageFee': 80, // fee for additional baggage
      'imagePath': 'assets/images/1.png'
    },
    {
      'flightNumber': 'EE345',
      'price': 180,
      'duration': 90, // in minutes
      'layovers': 0,
      'airline': 'Airline E',
      'baggageAllowance': 1, // in pieces
      'extraBaggageFee': 40, // fee for additional baggage
      'imagePath': 'assets/images/test.png'
    },
    {
      'flightNumber': 'FF678',
      'price': 320,
      'duration': 210, // in minutes
      'layovers': 1,
      'airline': 'Airline F',
      'baggageAllowance': 2, // in pieces
      'extraBaggageFee': 90, // fee for additional baggage
      'imagePath': 'assets/images/1.png'
    },
    {
      'flightNumber': 'GG901',
      'price': 400,
      'duration': 320, // in minutes
      'layovers': 0,
      'airline': 'Airline G',
      'baggageAllowance': 3, // in pieces
      'extraBaggageFee': 100, // fee for additional baggage
      'imagePath': 'assets/images/test.png'
    },
    {
      'flightNumber': 'HH234',
      'price': 275,
      'duration': 130, // in minutes
      'layovers': 1,
      'airline': 'Airline H',
      'baggageAllowance': 2, // in pieces
      'extraBaggageFee': 70, // fee for additional baggage
      'imagePath': 'assets/images/1.png'
    },
    {
      'flightNumber': 'II567',
      'price': 220,
      'duration': 160, // in minutes
      'layovers': 0,
      'airline': 'Airline I',
      'baggageAllowance': 1, // in pieces
      'extraBaggageFee': 55, // fee for additional baggage
      'imagePath': 'assets/images/test.png'
    },
    {
      'flightNumber': 'JJ890',
      'price': 150,
      'duration': 110, // in minutes
      'layovers': 2,
      'airline': 'Airline J',
      'baggageAllowance': 1, // in pieces
      'extraBaggageFee': 40, // fee for additional baggage
      'imagePath': 'assets/images/1.png'
    },
  ];

  List<Map<String, dynamic>> filteredResults = [];
  Set<int> expandedFlights = {};

  String selectedPriceRange = 'All';
  String selectedDuration = 'All';
  String selectedLayovers = 'All';
  String selectedAirline = 'All';

  @override
  void initState() {
    super.initState();
    filteredResults = flightResults;
  }

  void applyFilters() {
    setState(() {
      filteredResults = flightResults.where((flight) {
        bool matchesPrice = selectedPriceRange == 'All' ||
            (selectedPriceRange == 'Under \$100' && flight['price'] < 100) ||
            (selectedPriceRange == '\$100 - \$300' && flight['price'] >= 100 && flight['price'] <= 300) ||
            (selectedPriceRange == 'Above \$300' && flight['price'] > 300);

        bool matchesDuration = selectedDuration == 'All' ||
            (selectedDuration == 'Under 2 hours' && flight['duration'] < 120) ||
            (selectedDuration == '2 - 5 hours' && flight['duration'] >= 120 && flight['duration'] <= 300) ||
            (selectedDuration == 'Above 5 hours' && flight['duration'] > 300);

        bool matchesLayovers = selectedLayovers == 'All' ||
            (selectedLayovers == 'Non-stop' && flight['layovers'] == 0) ||
            (selectedLayovers == '1 Layover' && flight['layovers'] == 1) ||
            (selectedLayovers == '2+ Layovers' && flight['layovers'] > 1);

        bool matchesAirline = selectedAirline == 'All' || flight['airline'] == selectedAirline;

        return matchesPrice && matchesDuration && matchesLayovers && matchesAirline;
      }).toList();
    });
  }

  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedPriceRange,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPriceRange = newValue!;
                  });
                },
                items: <String>[
                  'All',
                  'Under \$100',
                  '\$100 - \$300',
                  'Above \$300',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: selectedDuration,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDuration = newValue!;
                  });
                },
                items: <String>[
                  'All',
                  'Under 2 hours',
                  '2 - 5 hours',
                  'Above 5 hours',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: selectedLayovers,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLayovers = newValue!;
                  });
                },
                items: <String>[
                  'All',
                  'Non-stop',
                  '1 Layover',
                  '2+ Layovers',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: selectedAirline,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAirline = newValue!;
                  });
                },
                items: <String>[
                  'All',
                  'Airline A',
                  'Airline B',
                  'Airline C',
                  'Airline D',
                  'Airline E',
                  'Airline F',
                  'Airline G',
                  'Airline H',
                  'Airline I',
                  'Airline J',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                applyFilters();
                Navigator.of(context).pop();
              },
              child: Text('Apply'),
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
        title: Text('Flight Results'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: showFilterDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredResults.length,
        itemBuilder: (context, index) {
          final flight = filteredResults[index];
          final isExpanded = expandedFlights.contains(index);
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Image.asset(
                    flight['imagePath'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  title: Text(flight['flightNumber']),
                  subtitle: Text('Price: \$${flight['price']}'),
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        expandedFlights.remove(index);
                      } else {
                        expandedFlights.add(index);
                      }
                    });
                  },
                ),
                if (isExpanded) _buildFlightDetails(flight),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlightDetails(Map<String, dynamic> flight) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Airline: ${flight['airline']}', style: TextStyle(fontSize: 16)),
          Text('Duration: ${flight['duration']} minutes', style: TextStyle(fontSize: 16)),
          Text('Layovers: ${flight['layovers']}', style: TextStyle(fontSize: 16)),
          Text('Baggage Allowance: ${flight['baggageAllowance']} pieces', style: TextStyle(fontSize: 16)),
          Text('Extra Baggage Fee: \$${flight['extraBaggageFee']}', style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Navigate to the booking screen with selected flight details
              Navigator.pushNamed(context, '/booking', arguments: flight);
            },
            child: Text('Book Now'),
          ),
        ],
      ),
    );
  }
}
