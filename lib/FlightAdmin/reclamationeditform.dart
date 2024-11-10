import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReclamationEditForm extends StatelessWidget {
  final DocumentSnapshot reclamation;

  ReclamationEditForm({required this.reclamation});

  @override
  Widget build(BuildContext context) {
    final reclamationData = reclamation.data() as Map<String, dynamic>;
    final TextEditingController reclamationController = TextEditingController(text: reclamationData['details']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Reclamation'),
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
                  // Update reclamation in Firestore
                  await reclamation.reference.update({
                    'details': reclamationController.text,
                  });
                  Navigator.pop(context); // Go back to ReclamationDetailsScreen
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
