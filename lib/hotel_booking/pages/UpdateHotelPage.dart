import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/hotel.dart';
import 'location_picker_screen.dart';

class UpdateHotelPage extends StatefulWidget {
  final Hotel hotel;

  const UpdateHotelPage({Key? key, required this.hotel}) : super(key: key);

  @override
  _UpdateHotelPageState createState() => _UpdateHotelPageState();
}

class _UpdateHotelPageState extends State<UpdateHotelPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _ratingController;
  late TextEditingController _reviewsController;
  late TextEditingController _distanceController;
  String? _imageUrl;
  late LatLng selectedLocation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.hotel.titleTxt);
    _locationController = TextEditingController(text: widget.hotel.subTxt);
    _priceController = TextEditingController(text: widget.hotel.perNight.toString());
    _ratingController = TextEditingController(text: widget.hotel.rating.toString());
    _reviewsController = TextEditingController(text: widget.hotel.reviews.toString());
    _distanceController = TextEditingController(text: widget.hotel.dist.toString());
    _imageUrl = widget.hotel.imagePath;
    selectedLocation = LatLng(widget.hotel.latitude, widget.hotel.longitude);
  }

  Future<void> _updateHotel() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('hotels').doc(widget.hotel.id).update({
          'titleTxt': _titleController.text,
          'subTxt': _locationController.text,
          'perNight': double.parse(_priceController.text),
          'rating': double.parse(_ratingController.text),
          'reviews': int.parse(_reviewsController.text),
          'imagePath': _imageUrl ?? '',
          'dist': double.parse(_distanceController.text),
          'latitude': selectedLocation.latitude,
          'longitude': selectedLocation.longitude,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hotel updated successfully')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating hotel')));
      }
    }
  }

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
      appBar: AppBar(title: Text('Update Hotel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Image'),
              ),
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
              ElevatedButton(
                onPressed: () async {
                  LatLng? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationPickerScreen(),
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
              ElevatedButton(
                onPressed: _updateHotel,
                child: Text('Update Hotel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
