import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/Reservation.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../services/stormglass_service.dart';


class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
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

  Position? _userLocation;
  List<LatLng> _polylineCoordinates = [];
  LatLng? _pickupLatLng;
  LatLng? _dropoffLatLng;
  bool _isRouteLoading = false;
  double _zoomLevel= 13.0;
  double _strokeWidthLevel = 4.0;
  double _markerwidthandheight = 30.0;

  final StormglassService stormglassService = StormglassService();
  Map<String, dynamic>? pickUpweatherData;
  Map<String, dynamic>? dropOffweatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCarDetails();
    _fetchDriverDetails();
    _getUserLocation();
  }

  Future<void> _submitBooking() async {
    String driverId = '';
    String? vehicleId;
    if (_selectedDriverDetails != null) {
      driverId = _selectedDriverDetails!['id'];
    } else {
      print('Driver not selected');
    }
    if (_selectedCarDetails != null) {
      vehicleId = _selectedCarDetails!['id'];
    } else {
      print('vehicle not selected');
    }
    final _bookingData = Reservation(
      reservationId:
          FirebaseFirestore.instance.collection('reservations').doc().id,
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
    await FirebaseFirestore.instance
        .collection('reservations')
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
          'details': doc['plateNumber'] + ' ' + doc['type'],
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
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
                  _selectedDriver = null;
                  _selectedDriverDetails = null;
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
                  _selectedDriver = null;
                  _selectedDriverDetails = null;
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
              decoration:
                  const InputDecoration(labelText: 'Time of First Pick-up'),
              child: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Choose Time',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ]
        else if (_withDriver == false) ...[
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

  Future<void> _getUserLocation() async {
    PermissionStatus permission = await Permission.location.request();
    if (permission.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _userLocation = position;
        });
      } catch (e) {
        print('Error getting location: $e');
        // Optionally, show a user-facing error message
      }
    } else {
      print('Location permission denied');
      // Optionally, show a dialog informing the user
    }
  }

  Future<void> _drawRoute(String pickup, String dropoff) async {
    // Example coordinates, you can replace these with your pickup/dropoff latitudes and longitudes
    final pickupLatLng = LatLng(40.7128, -74.0060); // Example: New York City
    final dropoffLatLng = LatLng(40.7306, -73.9352); // Example: Brooklyn, NY

    // Create the Mapbox API URL
    final url = 'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '${pickupLatLng.longitude},${pickupLatLng.latitude};${dropoffLatLng.longitude},${dropoffLatLng.latitude}'
        '?geometries=geojson&access_token=sk.eyJ1IjoiYW1pcmJvdWRpZGFoIiwiYSI6ImNtM2F1anprejA0Z3MyanNlcGk0Z3I2eDYifQ.eWhNkkCqdQSMvy7BmM7KxQ';

    // Make the HTTP request to Mapbox
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the response
      final data = json.decode(response.body);

      // Extract the polyline coordinates from the response
      List<dynamic> routeCoordinates = data['routes'][0]['geometry']['coordinates'];

      List<LatLng> coordinates = routeCoordinates
          .map((point) => LatLng(point[1], point[0]))
          .toList();
      setState(() {
        _polylineCoordinates = coordinates;
      });
    } else {
      print('Failed to load route: ${response.statusCode}');
    }
  }

  Future<LatLng?> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        double lat = locations[0].latitude;
        double lng = locations[0].longitude;

        // Validate coordinates
        if (lat.abs() <= 90 && lng.abs() <= 180) {
          return LatLng(lat, lng);
        } else {
          throw Exception("Coordinates out of bounds: ($lat, $lng)");
        }
      } else {
        throw Exception("No results found for this address");
      }
    } catch (e) {
      print("Error geocoding address: $e");
      return null; // Return null to indicate failure
    }
  }

  Future<void> _initiateRouteDrawing() async {
    setState(() {
      _isRouteLoading = true;
      _pickupLatLng = null;
      _dropoffLatLng = null;
      _polylineCoordinates = [];
    });

    try {
      List<LatLng?> results = await Future.wait([
        _getLatLngFromAddress(_pickupController.text),
        _getLatLngFromAddress(_dropoffController.text),
      ]);

      if (results[0] == null || results[1] == null) {
        throw Exception("Failed to geocode one or both addresses.");
      }

      setState(() {
        _pickupLatLng = results[0];
        _dropoffLatLng = results[1];
      });

      await _drawRoute(_pickupController.text, _dropoffController.text);

      // Calculate the distance between pickup and dropoff
      double distance = Geolocator.distanceBetween(
        _pickupLatLng!.latitude,
        _pickupLatLng!.longitude,
        _dropoffLatLng!.latitude,
        _dropoffLatLng!.longitude,
      );

      // Adjust zoom level based on the distance
      double zoomLevel = _getZoomLevel(distance);
      double markerwidthandheight = _getmarkerwidthandheightLevel(distance);
      double strokeWidthLevel = _getstrokeWidthLevel(distance);
      setState(() {
        _zoomLevel = zoomLevel; // Store the zoom level
        _strokeWidthLevel = strokeWidthLevel;
        _markerwidthandheight = markerwidthandheight;
      });
    } catch (e) {
      print('Error initiating route: $e');
    } finally {
      setState(() {
        _isRouteLoading = false;
      });
    }

    /*await fetchWeatherData(_pickupLatLng!.latitude, _pickupLatLng!.longitude, pickUpweatherData);
    await fetchWeatherData(_dropoffLatLng!.latitude, _dropoffLatLng!.longitude, dropOffweatherData);*/
  }

  double _getZoomLevel(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return 14.0; // High zoom for small distances
    } else if (distanceInMeters < 5000) {
      return 13.0;
    } else if (distanceInMeters < 10000) {
      return 12.0;
    } else if (distanceInMeters < 20000) {
      return 11.0;
    } else {
      return 10.0;
    }
  }

  double _getmarkerwidthandheightLevel(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return 20.0;
    } else if (distanceInMeters < 5000) {
      return 30.0;
    } else if (distanceInMeters < 10000) {
      return 40.0;
    } else if (distanceInMeters < 20000) {
      return 50.0;
    } else {
      return 60.0; // Low zoom for large distances
    }
  }

  double _getstrokeWidthLevel(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return 3.0;
    } else if (distanceInMeters < 5000) {
      return 4.0;
    } else if (distanceInMeters < 10000) {
      return 5.0;
    } else if (distanceInMeters < 20000) {
      return 6.0;
    } else {
      return 7.0; // Low zoom for large distances
    }
  }

  Widget _buildMapTaxi() {
    if (_isRouteLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pickupLatLng == null && _dropoffLatLng == null) {
      // Show user's location
      if (_userLocation == null) {
        return const Center(child: CircularProgressIndicator());
      }
      else {
        return FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(_userLocation!.latitude, _userLocation!.longitude),
            initialZoom: 13.0,
          ),
          children: [
            _buildTileLayer(),
            _buildMarkerLayer([
              Marker(
                point: LatLng(_userLocation!.latitude, _userLocation!.longitude),
                width: 30.0,
                height: 30.0,
                child: const Icon(Icons.location_pin, color: Colors.red),
              ),
            ]),
          ],
        );
      }
    }
    else if (_pickupLatLng != null && _dropoffLatLng != null) {
      return FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            (_pickupLatLng!.latitude + _dropoffLatLng!.latitude) / 2,
            (_pickupLatLng!.longitude + _dropoffLatLng!.longitude) / 2,
          ),
          initialZoom: _zoomLevel ?? 12.0,
        ),
        children: [
          _buildTileLayer(),
          if (_polylineCoordinates.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _polylineCoordinates,
                  strokeWidth: _strokeWidthLevel,
                  color: Colors.blue,
                ),
              ],
            ),
          _buildMarkerLayer([
            Marker(
              point: _pickupLatLng!,
              width: _markerwidthandheight,
              height: _markerwidthandheight,
              child: const Icon(Icons.location_pin, color: Colors.green),
            ),
            Marker(
              point: _dropoffLatLng!,
              width: _markerwidthandheight,
              height: _markerwidthandheight,
              child: const Icon(Icons.location_pin, color: Colors.blue),
            )
          ]),
        ],
      );
    }

    return const Center(child: Text('Invalid state or error.'));
  }

  TileLayer _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=sk.eyJ1IjoiYW1pcmJvdWRpZGFoIiwiYSI6ImNtM2F1anprejA0Z3MyanNlcGk0Z3I2eDYifQ.eWhNkkCqdQSMvy7BmM7KxQ',
      additionalOptions: {
        'accessToken': 'sk.eyJ1IjoiYW1pcmJvdWRpZGFoIiwiYSI6ImNtM2F1anprejA0Z3MyanNlcGk0Z3I2eDYifQ.eWhNkkCqdQSMvy7BmM7KxQ', // Replace with your actual Mapbox API key
      },
      tileProvider: NetworkTileProvider(), // Optional: prevent tile caching
    );
  }

  MarkerLayer _buildMarkerLayer(List<Marker> markers) {
    return MarkerLayer(
      markers: markers,
    );
  }

  Widget _buildTaxiFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: isLoading
              ? CircularProgressIndicator()
              : pickUpweatherData != null
              ? Text('Temperature: ${pickUpweatherData!['hours'][0]['airTemperature']['noaa']} °C')
              : Text('Failed to load weather data'),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _pickupController,
          decoration: const InputDecoration(labelText: 'Pick-up Location'),
          onSubmitted: (_) => _initiateRouteDrawing(), // Trigger route drawing on submission
        ),
        const SizedBox(height: 16),
        Center(
          child: isLoading
              ? CircularProgressIndicator()
              : dropOffweatherData != null
              ? Text('Temperature: ${dropOffweatherData!['hours'][0]['airTemperature']['noaa']} °C')
              : Text('Failed to load weather data'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dropoffController,
          decoration: const InputDecoration(labelText: 'Drop-off Location'),
          onSubmitted: (_) => _initiateRouteDrawing(),
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
        const SizedBox(height: 16),
        SizedBox(
          height: 300, // Adjust height as needed
          child: _buildMapTaxi(),
        ),
      ],
    );
  }

  Future<void> fetchWeatherData(double lat, double lng,Map<String, dynamic>? weatherData) async {
    try {
      final data = await stormglassService.fetchMarineData(lat,lng);
      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
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
                      _selectedDate = null;
                      _startDate = null;
                      _endDate = null;
                      _selectedTime = null;
                      _selectedCarType = null;
                      _withDriver = null;
                      _selectedDriver = null;
                      _selectedDriverDetails = null;
                      _selectedCarDetails = null;
                      _pickupController.clear();
                      _dropoffController.clear();
                      _carPickupLocationController.clear();
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
                      _selectedDate = null;
                      _startDate = null;
                      _endDate = null;
                      _selectedTime = null;
                      _selectedCarType = null;
                      _withDriver = null;
                      _selectedDriver = null;
                      _selectedDriverDetails = null;
                      _selectedCarDetails = null;
                      _pickupController.clear();
                      _dropoffController.clear();
                      _carPickupLocationController.clear();
                    });
                  },
                ),
                const Text('Personal Vehicle'),
              ],
            ),
            if (_selectedVehicleType == 'Taxi') _buildTaxiFields(),
            if (_selectedVehicleType == 'Personal Vehicle')
              _buildPersonalVehicleFields(),
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
