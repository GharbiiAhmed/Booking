import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  String? _imageUrl;
  File? _image;
  late LatLng selectedLocation;
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('hotels/${_image!.path.split('/').last}');
      await storageRef.putFile(_image!);
      String downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
      });
    } catch (e) {
      print("Image upload failed: $e");
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
        'imagePath': _imageUrl,
        'dist': double.parse(_distanceController.text),
        // Save latitude and longitude as part of the hotel data
        'latitude': selectedLocation.latitude,
        'longitude': selectedLocation.longitude,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hotel added successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add hotel')),
      );
    }
  }
} 
