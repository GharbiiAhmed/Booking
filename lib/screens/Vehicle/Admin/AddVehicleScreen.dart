import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../../models/Vehicle.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  String _selectedType = 'Car';
  String _selectedStatus = 'Available';
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void dispose() {
    _plateNumberController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final assetManifest = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(assetManifest);

      final assetList = manifestMap.keys
          .where((path) => path.contains('lib/resources/cars/') &&
          (path.endsWith('.png') || path.endsWith('.jpg')))
          .toList();

      if (assetList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No images found in resources/cars')),
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
                  final decodedPath = Uri.decodeFull(assetPath);
                  return ListTile(
                    leading: Image.asset(
                      decodedPath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(decodedPath.split('/').last),
                    onTap: () {
                      setState(() {
                        _imageUrl = decodedPath;
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


  Future<void> _addVehicle() async {
    if (_formKey.currentState!.validate()) {
      final vehicle = Vehicle(
        vehicleId: FirebaseFirestore.instance.collection('Vehicle').doc().id,
        plateNumber: _plateNumberController.text,
        type: _selectedType,
        status: _selectedStatus,
        model: _modelController.text,
        imageUrl: _imageUrl ?? '',
      );

      try {
        await FirebaseFirestore.instance.collection('Vehicles').doc(vehicle.vehicleId).set(vehicle.toMap());
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Vehicle added successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _imageUrl = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add vehicle: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Vehicle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _plateNumberController,
                decoration: InputDecoration(labelText: 'Plate Number'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter plate number' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: ['Car', 'Truck', 'Van']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
                decoration: InputDecoration(labelText: 'Type'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: ['Available', 'Unavailable', 'In Service']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
                decoration: InputDecoration(labelText: 'Status'),
              ),
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(labelText: 'Model'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter model' : null,
              ),
              SizedBox(height: 20),
              _imageUrl != null
                  ? Column(
                children: [
                  Image.asset(_imageUrl!, height: 100, width: 100, fit: BoxFit.cover),
                  TextButton(
                    onPressed: () => setState(() => _imageUrl = null),
                    child: Text('Clear Image'),
                  ),
                ],
              )
                  : TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Pick an image'),
              ),
              SizedBox(height: 20),
              _isUploading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _addVehicle,
                child: Text('Add Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
