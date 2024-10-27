import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_reservation/models//Driver.dart';

class AddDriverScreen extends StatefulWidget {
  @override
  _AddDriverScreenState createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _vehicleIdController = TextEditingController();

  Future<void> _addDriver() async {
    if (_formKey.currentState!.validate()) {
      final driver = Driver(
        driverId: FirebaseFirestore.instance.collection('Drivers').doc().id,
        name: _nameController.text,
        licenseNumber: _licenseNumberController.text,
        status: _statusController.text,
        vehicleId: _vehicleIdController.text,
      );

      await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(driver.driverId)
          .set(driver.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Driver added successfully!')),
      );

      // Clear the fields after submission
      _nameController.clear();
      _licenseNumberController.clear();
      _statusController.clear();
      _vehicleIdController.clear();
    }
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
                controller: _statusController,
                decoration: InputDecoration(labelText: 'Status'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the status';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _vehicleIdController,
                decoration: InputDecoration(labelText: 'Vehicle ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the vehicle ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addDriver,
                child: Text('Add Driver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
