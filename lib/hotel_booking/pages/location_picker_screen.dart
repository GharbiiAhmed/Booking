import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _isMapInitialized = false;

   void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _isMapInitialized = true; // Mark the map as initialized
      print('Map created successfully');

    setState(() {
      _selectedLocation = LatLng(37.7749, -122.4194); // Default location if no selection
    });
  }

  @override
  void dispose() {
    // Dispose the controller only if it’s initialized
    if (_isMapInitialized) {
      _mapController?.dispose();
    }
    super.dispose();
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                // Pass the selected location back to the previous screen
                Navigator.pop(context, _selectedLocation);
              },
            ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194), // Default to San Francisco
          zoom: 10.0,
        ),
        onTap: _onTap,
        markers: _selectedLocation != null
            ? {
                Marker(
                  markerId: MarkerId('selected-location'),
                  position: _selectedLocation!,
                ),
              }
            : {},
      ),
    );
  }
}
