import 'package:flutter/material.dart';
import 'hotel_results_page.dart'; // Assurez-vous d'importer votre page de résultats

class HotelSearchPage extends StatelessWidget {
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController arrivalDateController = TextEditingController();
  final TextEditingController departureDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel Booking'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6B8E23), // Couleur de début
              Color(0xFF3CB371), // Couleur de fin
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centrer verticalement
            crossAxisAlignment: CrossAxisAlignment.center, // Centrer horizontalement
            children: [
              Text(
                'Find Your Perfect Hotel',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center, // Centrer le texte
              ),
              SizedBox(height: 20),
              // Elevated TextField for Destination
              _buildTextField(
                controller: destinationController,
                labelText: 'Destination',
                hintText: 'Enter destination',
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Centrer horizontalement
                children: [
                  // Elevated TextField for Arrival Date
                  Expanded(
                    child: _buildTextField(
                      controller: arrivalDateController,
                      labelText: 'Check-in Date',
                      hintText: 'Select arrival date',
                    ),
                  ),
                  SizedBox(width: 10),
                  // Elevated TextField for Departure Date
                  Expanded(
                    child: _buildTextField(
                      controller: departureDateController,
                      labelText: 'Check-out Date',
                      hintText: 'Select departure date',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HotelResultsPage(
                        destination: destinationController.text,
                        arrivalDate: arrivalDateController.text,
                        departureDate: departureDateController.text,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30), // Augmentez l'espace vertical et horizontal pour élargir le bouton
                  backgroundColor: Colors.white, // Couleur du bouton (ajustez comme nécessaire)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Arrondi du bouton (augmentez si vous voulez plus de rondeur)
                  ),
                  textStyle: TextStyle(fontSize: 18), // Taille du texte
                ),
                child: Text('Search Hotels'),
              ),



            ],
          ),
        ),
      ),
    );
  }

  // Widget pour créer les TextFields avec un style uniforme
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return Material(
      elevation: 5.0,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black54),
          border: OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }
}
