import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _selectedTime;
  String? _selectedCarType;
  String? _selectedVehicleType;
  bool? _withDriver;
  String? _selectedDriver;
  Map<String, String>? _selectedDriverDetails;
  Map<String, String>? _selectedCarDetails; // Change to Map<String, String>?

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final TextEditingController _carPickupLocationController = TextEditingController();

  final List<Map<String, String>> _drivers = [
    {'name': 'John Doe', 'image': 'assets/john_doe.png', 'details': 'Experienced driver with 5 years of service.'},
    {'name': 'Jane Smith', 'image': 'assets/jane_smith.png', 'details': 'Friendly and punctual driver.'},
    {'name': 'Bob Johnson', 'image': 'assets/bob_johnson.png', 'details': 'Knows the city well, great ratings.'},
  ];

  final List<Map<String, String>> _carDetails = [
    {
      'name': 'Sedan',
      'image': 'assets/sedan.png',
      'details': 'A comfortable car for city driving.'
    },
    {
      'name': 'SUV',
      'image': 'assets/suv.png',
      'details': 'Spacious and perfect for off-road adventures.'
    },
    {
      'name': 'Luxury',
      'image': 'assets/luxury.png',
      'details': 'A premium vehicle for a luxurious experience.'
    },
    {
      'name': 'Van',
      'image': 'assets/van.png',
      'details': 'Ideal for larger groups or families.'
    },
  ];

  Future<void> _selectDate(BuildContext context, {bool isStart = false, bool isEnd = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else if (isEnd) {
          _endDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Widget _buildCarTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Car Type',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _carDetails.map((car) {
              final isSelected = car['name'] == _selectedCarType;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCarType = car['name'];
                    _selectedCarDetails = car; // Store selected car details
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    children: [
                      Image.asset(car['image']!, height: 60), // Car type image
                      const SizedBox(height: 8),
                      Text(
                        car['name']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCarType = car['name'];
                            _selectedCarDetails = car; // Store selected car details
                          });
                        },
                        child: Text(
                          'Details',
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.blue,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedCarDetails != null) // Display car type details if selected
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Details for ${_selectedCarDetails!['name']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_selectedCarDetails!['details']!), // Show car type details
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDriverSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Driver',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _drivers.map((driver) {
              final isSelected = driver['name'] == _selectedDriver;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDriver = driver['name'];
                    _selectedDriverDetails = driver; // Store selected driver details
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(driver['image']!),
                        radius: 40, // Larger image
                      ),
                      const SizedBox(height: 8),
                      Text(
                        driver['name']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDriver = driver['name'];
                            _selectedDriverDetails = driver; // Store selected driver details
                          });
                        },
                        child: Text(
                          'Details',
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.blue,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedDriverDetails != null) // Display driver details if selected
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Details for ${_selectedDriverDetails!['name']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_selectedDriverDetails!['details']!), // Show driver details
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPersonalVehicleFields() {
    return Column(
      children: [
        Row(
          children: [
            const Text('With Driver: '),
            Radio<bool>(
              value: true,
              groupValue: _withDriver,
              onChanged: (bool? value) {
                setState(() {
                  _withDriver = value;
                });
              },
            ),
            const Text('Yes'),
            Radio<bool>(
              value: false,
              groupValue: _withDriver,
              onChanged: (bool? value) {
                setState(() {
                  _withDriver = value;
                });
              },
            ),
            const Text('No'),
          ],
        ),
        if (_withDriver == true) ...[
          _buildDriverSelection(),
          const SizedBox(height: 16),
          TextField(
            controller: _pickupController,
            decoration: const InputDecoration(labelText: 'Pick-up Location'),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context, isStart: true),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Start Date'),
              child: Text(
                _startDate != null
                    ? _dateFormatter.format(_startDate!)
                    : 'Choose Start Date',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context, isEnd: true),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'End Date'),
              child: Text(
                _endDate != null
                    ? _dateFormatter.format(_endDate!)
                    : 'Choose End Date',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectTime(context),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Time of First Pick-up'),
              child: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Choose Time',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ] else if (_withDriver == false) ...[
          InkWell(
            onTap: () => _selectDate(context, isStart: true),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Start Date'),
              child: Text(
                _startDate != null
                    ? _dateFormatter.format(_startDate!)
                    : 'Choose Start Date',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context, isEnd: true),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'End Date'),
              child: Text(
                _endDate != null
                    ? _dateFormatter.format(_endDate!)
                    : 'Choose End Date',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _carPickupLocationController,
            decoration: const InputDecoration(labelText: 'Car Pickup Location'),
          ),
        ],
        const SizedBox(height: 16),
        _buildCarTypeSelection(),
      ],
    );
  }

  Widget _buildTaxiFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _pickupController,
          decoration: const InputDecoration(labelText: 'Pick-up Location'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dropoffController,
          decoration: const InputDecoration(labelText: 'Drop-off Location'),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Date'),
            child: Text(
              _selectedDate != null
                  ? _dateFormatter.format(_selectedDate!)
                  : 'Choose Date',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectTime(context),
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Pick-up Time'),
            child: Text(
              _selectedTime != null
                  ? _selectedTime!.format(context)
                  : 'Choose Time',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Vehicle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Vehicle Type:'),
            Row(
              children: [
                Radio<String>(
                  value: 'Taxi',
                  groupValue: _selectedVehicleType,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedVehicleType = value;
                    });
                  },
                ),
                const Text('Taxi'),
                Radio<String>(
                  value: 'Personal Vehicle',
                  groupValue: _selectedVehicleType,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedVehicleType = value;
                    });
                  },
                ),
                const Text('Personal Vehicle'),
              ],
            ),
            if (_selectedVehicleType == 'Taxi') _buildTaxiFields(),
            if (_selectedVehicleType == 'Personal Vehicle') _buildPersonalVehicleFields(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Booking confirmation logic
                // You can display a dialog or navigate to another screen to confirm the booking
              },
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
