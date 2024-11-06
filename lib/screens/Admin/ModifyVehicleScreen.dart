import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/Vehicle.dart';

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
  String _selectedType = 'Car';
  String _selectedStatus = 'Available';
  String? _selectedImagePath;
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: assetList.map((assetPath) {
                final decodedPath = Uri.decodeFull(assetPath);
                return ListTile(
                  title: Text(decodedPath.split('/').last),
                  onTap: () {
                    setState(() {
                      _selectedImagePath = decodedPath;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
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



  Future<void> _uploadImage() async {
    if (_selectedImagePath == null) return;

    setState(() => _isUploading = true);
    try {
      _imageUrl = _selectedImagePath;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _updateVehicle() async {
    if (_formKey.currentState!.validate()) {
      // If an image is selected, upload it
      if (_selectedImagePath != null) await _uploadImage();

      final vehicle = Vehicle(
        vehicleId: widget.vehicle.vehicleId,
        plateNumber: _plateNumberController.text,
        type: _selectedType,
        status: _selectedStatus,
        model: _modelController.text,
        imageUrl: _imageUrl ?? '',
      );

      try {
        // Update vehicle details in Firestore
        await FirebaseFirestore.instance.collection('Vehicles').doc(vehicle.vehicleId).set(vehicle.toMap());

        // Show success popup dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Vehicle updated successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Close dialog
                child: Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update vehicle: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _plateNumberController.text = widget.vehicle.plateNumber;
    _modelController.text = widget.vehicle.model;
    _selectedType = widget.vehicle.type;
    _selectedStatus = widget.vehicle.status;
    _imageUrl = widget.vehicle.imageUrl;
    _selectedImagePath = _imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modify Vehicle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _plateNumberController,
                decoration: InputDecoration(labelText: 'Plate Number'),
                validator: (value) => value!.isEmpty ? 'Please enter plate number' : null,
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
                validator: (value) => value!.isEmpty ? 'Please enter model' : null,
              ),
              SizedBox(height: 20),
              (_selectedImagePath != null || _imageUrl != null)
                  ? Stack(
                alignment: Alignment.topRight,
                children: [
                  if (_selectedImagePath != null)
                    Image.asset(
                      _selectedImagePath!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  else if (_imageUrl != null)
                    Image.network(
                      _imageUrl!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        }
                      },
                    ),
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedImagePath = null;
                        _imageUrl = null;
                      });
                    },
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

