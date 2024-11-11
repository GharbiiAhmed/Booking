import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:taxi_reservation/models/Driver.dart';

class AddDriverScreen extends StatefulWidget {
  const AddDriverScreen({super.key});

  @override
  _AddDriverScreenState createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedStatus;
  String _profileImageUrl = '';

  Future<void> _pickImage() async {
    try {
      final assetManifest = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(assetManifest);

      final assetList = manifestMap.keys
          .where((path) => path.contains('lib/resources/drivers/') &&
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
                        _profileImageUrl = assetPath;
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

  Future<void> _addDriver() async {
    if (_formKey.currentState!.validate()) {
      if (_profileImageUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a profile image')),
        );
        return;
      }

      final driver = Driver(
        driverId: FirebaseFirestore.instance.collection('Drivers').doc().id,
        name: _nameController.text,
        licenseNumber: _licenseNumberController.text,
        description: _descriptionController.text,
        status: _selectedStatus!,
        profileImageUrl: _profileImageUrl,
      );

      await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(driver.driverId)
          .set(driver.toMap());

      // Show a pop-up dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Driver added successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );

      _nameController.clear();
      _licenseNumberController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedStatus = null;
        _profileImageUrl = '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licenseNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Driver'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the driver\'s name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _licenseNumberController,
                  decoration: InputDecoration(labelText: 'License Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the license number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(labelText: 'Status'),
                  items: ['Available', 'Unavailable', 'In Service']
                      .map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the status';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _profileImageUrl.isNotEmpty
                    ? Image.asset(_profileImageUrl)
                    : Text('No image selected'),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Choose Profile Image'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addDriver,
                  child: Text('Add Driver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
