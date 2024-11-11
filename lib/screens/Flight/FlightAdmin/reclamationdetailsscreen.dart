import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReclamationDetailsScreen extends StatelessWidget {
  final DocumentSnapshot reclamation; // Expecting a reclamation document

  const ReclamationDetailsScreen({Key? key, required this.reclamation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reclamationData = reclamation.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reclamation Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reclamation ID: ${reclamation.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Username: ${reclamationData['username']}'),
            Text('Email: ${reclamationData['email']}'),
            const SizedBox(height: 10),
            Text('Details: ${reclamationData['details']}'),
            const SizedBox(height: 10),
            Text('Created At: ${reclamationData['createdAt']?.toDate()}'),
            const SizedBox(height: 20),

            // You can add more details or actions related to this reclamation here
          ],
        ),
      ),
    );
  }
}
