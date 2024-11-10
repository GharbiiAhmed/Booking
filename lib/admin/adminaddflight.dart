import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class CreateFlightScreen extends StatefulWidget {
  const CreateFlightScreen({Key? key}) : super(key: key);

  @override
  _CreateFlightScreenState createState() => _CreateFlightScreenState();
}

class _CreateFlightScreenState extends State<CreateFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  final _flightNumberController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _layoversController = TextEditingController();
  final _airlineController = TextEditingController();
  final _baggageAllowanceController = TextEditingController();
  final _extraBaggageFeeController = TextEditingController();
  final _imagePathController = TextEditingController();

  // New controllers for origin and destination
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Flight')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_flightNumberController, 'Flight Number'),
              _buildTextField(_priceController, 'Price', isNumeric: true),
              _buildTextField(_durationController, 'Duration (min)', isNumeric: true),
              _buildTextField(_layoversController, 'Layovers', isNumeric: true),
              _buildTextField(_airlineController, 'Airline'),
              _buildTextField(_baggageAllowanceController, 'Baggage Allowance', isNumeric: true),
              _buildTextField(_extraBaggageFeeController, 'Extra Baggage Fee', isNumeric: true),
              _buildTextField(_imagePathController, 'Image Path'),

              // New fields for origin and destination
              _buildTextField(_originController, 'Origin'),
              _buildTextField(_destinationController, 'Destination'),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _firebaseService.createFlight(
                      flightNumber: _flightNumberController.text,
                      price: double.parse(_priceController.text),
                      duration: int.parse(_durationController.text),
                      layovers: int.parse(_layoversController.text),
                      airline: _airlineController.text,
                      baggageAllowance: int.parse(_baggageAllowanceController.text),
                      extraBaggageFee: double.parse(_extraBaggageFeeController.text),
                      imagePath: _imagePathController.text,
                      origin: _originController.text,  // Add origin to the method call
                      destination: _destinationController.text,  // Add destination to the method call
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create Flight'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }
}
