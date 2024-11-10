import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReclamationForm extends StatelessWidget {
  const ReclamationForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController reclamationController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reclamation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: reclamationController,
              decoration: const InputDecoration(labelText: 'Reclamation Details'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (reclamationController.text.isNotEmpty) {
                  // Save reclamation to Firestore
                  await FirebaseFirestore.instance.collection('reclamations').add({
                    'details': reclamationController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                    'paymentId': '', // To be filled when linking with payments
                  });
                  Navigator.pop(context); // Go back to UserDashboard
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
