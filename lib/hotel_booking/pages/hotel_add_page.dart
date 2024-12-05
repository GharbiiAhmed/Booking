import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../home_screen.dart';
import '../../navigation_home_screen.dart';
import 'location_picker_screen.dart';

class AddHotelScreen extends StatefulWidget {
  @override
  _AddHotelScreenState createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController();
  final _reviewsController = TextEditingController();
  final _distanceController = TextEditingController();
  String? _imageUrl = '';
  File? _image;
  late LatLng selectedLocation = LatLng(36.8065, 10.1815);
  Future<void> _pickImage() async {
    try {
      final assetManifest = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(assetManifest);

      final assetList = manifestMap.keys
          .where((path) => path.contains('assets/hotel/') &&
          (path.endsWith('.png') || path.endsWith('.jpg')))
          .toList();

      if (assetList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No images found in resources/drivers')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select an image'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: assetList.map((assetPath) {
                  return ListTile(
                    leading: Image.asset(
                      assetPath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(assetPath.split('/').last),
                    onTap: () {
                      setState(() {
                        _imageUrl = assetPath;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading images: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Hotel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Hotel Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the hotel title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price per Night'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: 'Rating (0-5)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the rating';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _reviewsController,
                decoration: InputDecoration(labelText: 'Number of Reviews'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of reviews';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Image'),
              ),
              SizedBox(height: 10),
              _imageUrl != null
                  ? Text('Image uploaded: $_imageUrl')
                  : Container(),
              TextFormField(
                controller: _distanceController,
                decoration: InputDecoration(labelText: 'Distance to City (km)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the distance';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  LatLng? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LocationPickerScreen(), // A screen to select location on the map
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      selectedLocation = result;

                    });
                  }
                },
                child: Text('Select Location on Map'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addHotel();
                  }
                },
                child: Text('Add Hotel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addHotel() async {
    try {
      await FirebaseFirestore.instance.collection('hotels').add({
        'titleTxt': _titleController.text,
        'subTxt': _locationController.text,
        'perNight': double.parse(_priceController.text),
        'rating': double.parse(_ratingController.text),
        'reviews': int.parse(_reviewsController.text),
        'imagePath': _imageUrl ?? '',
        'dist': double.parse(_distanceController.text),
        'latitude': selectedLocation.latitude ?? 0.0,
        'longitude': selectedLocation.longitude ?? 0.0,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hotel added successfully!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => NavigationHomeScreen(), // Replace with your desired screen
        ),
      );

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add hotel')),
      );
    }
  }
}
