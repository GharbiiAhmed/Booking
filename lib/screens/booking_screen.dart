
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/Reservation.dart';

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
  String _selectedVehicleType = '';
  bool? _withDriver;
  String? _selectedDriver;
  Map<String, dynamic>? _selectedDriverDetails;
  Map<String, dynamic>? _selectedCarDetails;

  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy');
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final TextEditingController _carPickupLocationController = TextEditingController();

  List<Map<String, dynamic>> _drivers = [];
  List<Map<String, dynamic>> _carDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchCarDetails();
    _fetchDriverDetails();
  }

  Future<void> _submitBooking() async {
    String driverId = '';
    String? vehicleId;
    if (_selectedDriverDetails != null )
    {
      driverId = _selectedDriverDetails!['id'];

    } else {
      print('Driver not selected');
    }
    if(_selectedCarDetails != null)
      {
        vehicleId = _selectedCarDetails!['id'];
      }
    else {
      print('vehicle not selected');
    }
    final _bookingData = Reservation(
      reservationId : FirebaseFirestore.instance.collection('reservations').doc().id,
      userId: '1',
      driverId: driverId,
      vehicleId: vehicleId,
      reservationDate: DateTime.now(),
      state: 'OnGoing',
      type: _selectedVehicleType,
      pickupLocation: _pickupController.text,
      dropoffLocation: _dropoffController.text,
      startDate: _startDate,
      endDate: _endDate,
      pickupTime: _selectedTime?.format(context),
    );
    await FirebaseFirestore.instance.collection('reservations')
        .doc(_bookingData.reservationId)
        .set(_bookingData.toMap());
  }


  Future<void> _fetchCarDetails() async {
    final carCollection = FirebaseFirestore.instance.collection('Vehicles');
    final carSnapshots = await carCollection.get();
    setState(() {
      _carDetails = carSnapshots.docs.map((doc) {
        return {
          'id': doc['vehicleId'],
          'name': doc['model'],
          'image': doc['imageUrl'],
          'details': doc['plateNumber']+' ' + doc['type'],
        };
      }).toList();
    });
  }

  Future<void> _fetchDriverDetails() async {
    final driverCollection = FirebaseFirestore.instance.collection('Drivers');
    final driverSnapshots = await driverCollection.get();
    setState(() {
      _drivers = driverSnapshots.docs.map((doc) {
        return {
          'id': doc['driverId'],
          'name': doc['name'],
          'image': doc['profileImageUrl'],
          'description': doc['description'],
        };
      }).toList();
    });
  }

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
                    _selectedCarDetails = car;
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
                      Image.asset(car['image']!, height: 60),
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
                            _selectedCarDetails = car;
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
        if (_selectedCarDetails != null)
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
                Text(_selectedCarDetails!['details']!),
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
                    _selectedDriverDetails = driver;
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
                        radius: 40,
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
                            _selectedDriverDetails = driver;
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
        if (_selectedDriverDetails != null)
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
                Text(_selectedDriverDetails!['description']!),
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
      body: SingleChildScrollView(
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
                      _selectedVehicleType = value!;
                    });
                  },
                ),
                const Text('Taxi'),
                Radio<String>(
                  value: 'Personal Vehicle',
                  groupValue: _selectedVehicleType,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedVehicleType = value!;
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
              onPressed: () async {
                try {
                  _submitBooking();

                  Navigator.pushNamed(context, '/confirmation');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to book vehicle: $e')),
                  );
                }
              },
              child: const Text('Confirm Booking'),
            ),

          ],
        ),
      ),
    );
  }

}
