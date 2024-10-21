import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Complete Your Payment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Ajoutez ici des champs pour les détails de paiement, comme un numéro de carte, une date d'expiration, etc.
            TextField(
              decoration: InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Expiry Date (MM/YY)',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'CVV',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action pour traiter le paiement
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30), // Augmentez l'espace vertical et horizontal pour élargir le bouton
                backgroundColor: Colors.white, // Couleur du bouton (ajustez comme nécessaire)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Arrondi du bouton (augmentez si vous voulez plus de rondeur)
                ),
                textStyle: TextStyle(fontSize: 18), // Taille du texte
              ),
              child: Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
