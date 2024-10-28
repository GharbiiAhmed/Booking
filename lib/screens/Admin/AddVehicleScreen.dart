import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
  File? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false; // To manage loading state

  @override
  void dispose() {
    _plateNumberController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true); // Start loading state
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('vehicle_images')
          .child('${_plateNumberController.text}_${DateTime.now().toIso8601String()}.jpg');

      await storageRef.putFile(_selectedImage!);
      _imageUrl = await storageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    } finally {
      setState(() => _isUploading = false); // End loading state
    }
  }

  Future<void> _addVehicle() async {
    if (_formKey.currentState!.validate()) {
      await _uploadImage(); // Upload image before adding vehicle

      final vehicle = {
        'plateNumber': _plateNumberController.text,
        'type': _selectedType,
        'status': _selectedStatus,
        'model': _modelController.text,
        'imageUrl': _imageUrl ?? '',
      };

      try {
        await FirebaseFirestore.instance.collection('Vehicles').add(vehicle);
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
          _selectedImage = null;
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
              _selectedImage != null
                  ? Column(
                children: [
                  Image.file(_selectedImage!, height: 100, width: 100, fit: BoxFit.cover),
                  TextButton(
                    onPressed: () => setState(() => _selectedImage = null),
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
