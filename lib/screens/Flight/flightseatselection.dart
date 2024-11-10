import 'package:flutter/material.dart';

class SeatSelectionScreen extends StatefulWidget {
  @override
  _SeatSelectionScreenState createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  List<List<bool>> seats = [
    [true, true, false, true, true], // true = available, false = unavailable (aisle)
    [true, true, false, true, false],
    [false, true, false, true, true],
  ];

  String? selectedSeat; // Store the selected seat

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Your Seat')),
      body: Column(
        children: [
          // Add the plane shape image at the top
          Image.asset(
            'assets/images/planeshape.png', // Make sure the image path is correct
            height: 150,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 16),

          // Seat layout below the image
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // 2 seats on the left, aisle (middle), 2 seats on the right
                childAspectRatio: 0.9, // Adjust the ratio for the seat and label spacing
              ),
              itemCount: seats.length * seats[0].length,
              itemBuilder: (context, index) {
                int row = index ~/ seats[0].length;
                int col = index % seats[0].length;
                bool isAvailable = seats[row][col];
                String seatLabel = '${String.fromCharCode(65 + row)}${col + 1}'; // Seat labels (A1, A2, etc.)

                // Skip the middle seat to represent the aisle
                if (col == 2) {
                  return Center(child: Text('')); // Empty space for aisle
                }

                return GestureDetector(
                  onTap: isAvailable
                      ? () {
                    setState(() {
                      selectedSeat = seatLabel; // Update selected seat
                    });
                  }
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/seat.png', // Path to seat.png image
                        height: 40,
                        color: isAvailable
                            ? (selectedSeat == seatLabel ? Colors.blue : null) // Blue if selected
                            : Colors.red.withOpacity(0.6), // Red overlay for unavailable seats
                      ),
                      SizedBox(height: 8), // Space between the seat and label
                      Text(
                        seatLabel,
                        style: TextStyle(
                          color: isAvailable
                              ? (selectedSeat == seatLabel ? Colors.blue : Colors.black)
                              : Colors.red, // Color for the label (unavailable in red)
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedSeat != null) {
            Navigator.pop(context, selectedSeat); // Return the selected seat
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select a seat')),
            );
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
