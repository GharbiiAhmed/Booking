import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class UpdateFlightScreen extends StatefulWidget {
  final String flightId;
  final Map<String, dynamic> initialFlightData;

  const UpdateFlightScreen({
    Key? key,
    required this.flightId,
    required this.initialFlightData,
  }) : super(key: key);

  @override
  _UpdateFlightScreenState createState() => _UpdateFlightScreenState();
}

class _UpdateFlightScreenState extends State<UpdateFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController _flightNumberController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _layoversController;
  late TextEditingController _airlineController;
  late TextEditingController _baggageAllowanceController;
  late TextEditingController _extraBaggageFeeController;
  late TextEditingController _imagePathController;
  late TextEditingController _originController;
  late TextEditingController _destinationController;

  @override
  void initState() {
    super.initState();
    _flightNumberController = TextEditingController(text: widget.initialFlightData['flightNumber']);
    _priceController = TextEditingController(text: widget.initialFlightData['price'].toString());
    _durationController = TextEditingController(text: widget.initialFlightData['duration'].toString());
    _layoversController = TextEditingController(text: widget.initialFlightData['layovers'].toString());
    _airlineController = TextEditingController(text: widget.initialFlightData['airline']);
    _baggageAllowanceController = TextEditingController(text: widget.initialFlightData['baggageAllowance'].toString());
    _extraBaggageFeeController = TextEditingController(text: widget.initialFlightData['extraBaggageFee'].toString());
    _imagePathController = TextEditingController(text: widget.initialFlightData['imagePath']);
    _originController = TextEditingController(text: widget.initialFlightData['origin']);
    _destinationController = TextEditingController(text: widget.initialFlightData['destination']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Flight')),
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
              _buildTextField(_originController, 'Origin'),
              _buildTextField(_destinationController, 'Destination'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await _firebaseService.updateFlight(
                        widget.flightId, // Pass as positional argument
                        flightNumber: _flightNumberController.text,
                        price: double.parse(_priceController.text),
                        duration: int.parse(_durationController.text),
                        layovers: int.parse(_layoversController.text),
                        airline: _airlineController.text,
                        baggageAllowance: int.parse(_baggageAllowanceController.text),
                        extraBaggageFee: double.parse(_extraBaggageFeeController.text),
                        imagePath: _imagePathController.text,
                        origin: _originController.text,
                        destination: _destinationController.text,
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update flight: $e')),
                      );
                    }
                  }
                },
                child: const Text('Update Flight'),
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
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  @override
  void dispose() {
    _flightNumberController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _layoversController.dispose();
    _airlineController.dispose();
    _baggageAllowanceController.dispose();
    _extraBaggageFeeController.dispose();
    _imagePathController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
}

