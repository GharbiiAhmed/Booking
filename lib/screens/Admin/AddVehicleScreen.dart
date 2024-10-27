import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _driverIdController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  String _selectedType = 'Car';
  String _selectedStatus = 'Available';

  @override
  void dispose() {
    _plateNumberController.dispose();
    _driverIdController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _addVehicle() async {
    if (_formKey.currentState!.validate()) {
      final vehicle = {
        'plateNumber': _plateNumberController.text,
        'type': _selectedType,
        'driverId': _driverIdController.text,
        'status': _selectedStatus,
        'model': _modelController.text,
      };

      try {
        await FirebaseFirestore.instance.collection('Vehicles').add(vehicle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle added successfully!')),
        );
        _formKey.currentState!.reset(); // Clear form after submission
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
              TextFormField(
                controller: _driverIdController,
                decoration: InputDecoration(labelText: 'Driver ID'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter driver ID' : null,
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
              ElevatedButton(
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
