import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:taxi_reservation/models/Driver.dart';
import 'package:path/path.dart';


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
  File? _profileImage;



  Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = basename(imageFile.path); // Use path package for filename
      Reference ref = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }


  Future<List<String>> _fetchVehicleIds() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Vehicles')
        .where('status', isEqualTo: 'Available')
        .get();
    return querySnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _addDriver() async {
    if (_formKey.currentState!.validate()) {
      String profileImageUrl = '';

      // Upload image if one was selected
      if (_profileImage != null) {
        profileImageUrl = await _uploadImage(_profileImage!);
      }

      final driver = Driver(
        driverId: FirebaseFirestore.instance.collection('Drivers').doc().id,
        name: _nameController.text,
        licenseNumber: _licenseNumberController.text,
        description: _descriptionController.text,
        status: _selectedStatus!,
        profileImageUrl: profileImageUrl,
      );

      await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(driver.driverId)
          .set(driver.toMap());

      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Driver added successfully!')),
      );

      // Clear the fields after submission
      _nameController.clear();
      _licenseNumberController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedStatus = null;
        _profileImage = null;
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
                _profileImage != null
                    ? Image.file(_profileImage!)
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
