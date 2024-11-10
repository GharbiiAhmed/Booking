import 'package:flutter/material.dart';
import '../../services/FlightFirebase/firebase_service.dart';


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
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  String? _tripType;
  DateTime? _departureDate;
  DateTime? _returnDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Flight')),
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

              // Dropdown for trip type selection
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Trip Type'),
                value: _tripType,
                items: ['One Way', 'Round Trip'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tripType = value;
                    // Reset return date when switching trip types
                    if (_tripType == 'One Way') {
                      _returnDate = null;
                    }
                  });
                },
                validator: (value) => value == null ? 'Please select a trip type' : null,
              ),

              // Date picker for departure date
              const SizedBox(height: 16),
              _buildDatePicker(
                label: 'Departure Date',
                selectedDate: _departureDate,
                onDateSelected: (DateTime date) {
                  setState(() {
                    _departureDate = date;
                  });
                },
              ),

              // Conditionally show return date picker if Round Trip is selected
              if (_tripType == 'Round Trip') ...[
                const SizedBox(height: 16),
                _buildDatePicker(
                  label: 'Return Date',
                  selectedDate: _returnDate,
                  onDateSelected: (DateTime date) {
                    setState(() {
                      _returnDate = date;
                    });
                  },
                ),
              ],

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_departureDate == null) {
                      // Ensure departure date is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a departure date')),
                      );
                      return;
                    }

                    await _firebaseService.createFlight(
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
                      tripType: _tripType!, // Pass the selected trip type
                      departureDate: _departureDate!.toIso8601String(), // Format date to string
                      returnDate: _tripType == 'Round Trip' ? _returnDate?.toIso8601String() : null, // Only include return date for round trip
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

  // Build the Date Picker for Departure and Return dates
  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        DateTime initialDate = selectedDate ?? DateTime.now();
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null && pickedDate != selectedDate) {
          onDateSelected(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          selectedDate != null
              ? '${selectedDate.toLocal()}'.split(' ')[0]
              : 'Select a date',
        ),
      ),
    );
  }
}
