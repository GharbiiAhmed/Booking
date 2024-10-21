import 'package:flutter/material.dart';
import 'payment_page.dart'; // Assurez-vous d'importer la page de paiement

class HotelResultsPage extends StatelessWidget {
  final String destination;
  final String arrivalDate;
  final String departureDate;

  HotelResultsPage({
    required this.destination,
    required this.arrivalDate,
    required this.departureDate,
  });

  final List<Map<String, String>> hotels = [
    {
      'name': 'Luxury Hotel',
      'location': 'Paris',
      'image': 'assets/images/image1.jpg',
    },
    {
      'name': 'Plaza Hotel',
      'location': 'New York',
      'image': 'assets/images/image2.jpg',
    },
    // Ajoutez d'autres hôtels ici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel Results'),
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
        child: ListView.builder(
          itemCount: hotels.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.all(8.0),
              elevation: 5.0,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    hotels[index]['image']!,
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  ),
                ),
                title: Text(
                  hotels[index]['name']!,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  hotels[index]['location']!,
                  style: TextStyle(color: Colors.black54),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Naviguer vers la page de paiement
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PaymentPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30), // Espace vertical
                    backgroundColor: Colors.white, // Remplacez par la couleur de votre choix
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // Arrondi du bouton
                    ),
                    textStyle: TextStyle(fontSize: 18), // Taille du texte
                  ),
                  child: Text('Book Now'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
