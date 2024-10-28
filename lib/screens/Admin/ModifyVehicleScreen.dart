import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_reservation/models/Vehicle.dart';

class ModifyVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;

  const ModifyVehicleScreen({super.key, required this.vehicle});

  @override
  _ModifyVehicleScreenState createState() => _ModifyVehicleScreenState();
}

class _ModifyVehicleScreenState extends State<ModifyVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _plateNumberController.text = widget.vehicle.plateNumber;
    _modelController.text = widget.vehicle.model;
    _statusController.text = widget.vehicle.status;
  }

  Future<void> _updateVehicle() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('Vehicles')
          .doc(widget.vehicle.vehicleId)
          .update({
        'plateNumber': _plateNumberController.text,
        'model': _modelController.text,
        'status': _statusController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle updated successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _modelController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Vehicle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _plateNumberController,
                decoration: InputDecoration(labelText: 'Plate Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the plate number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(labelText: 'Model'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the model';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _statusController.text.isNotEmpty ? _statusController.text : null,
                decoration: InputDecoration(labelText: 'Status'),
                items: ['Available', 'Unavailable', 'In Service']
                    .map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _statusController.text = newValue;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateVehicle,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
