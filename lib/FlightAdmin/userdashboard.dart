import 'package:flight_reservation/FlightAdmin/reclamationdetailsscreen.dart';
import 'package:flight_reservation/FlightAdmin/reclamationeditform.dart';
import 'package:flight_reservation/FlightAdmin/reclamationform.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Optionally implement refresh functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reclamations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading reclamations'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reclamations found.'));
          }

          final reclamations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reclamations.length,
            itemBuilder: (context, index) {
              final reclamation = reclamations[index];
              final reclamationData = reclamation.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text('Reclamation ID: ${reclamation.id}'),
                  subtitle: Text('Details: ${reclamationData['details']} \nCreated At: ${reclamationData['createdAt']?.toDate()}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigate to edit reclamation form
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReclamationEditForm(reclamation: reclamation),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          try {
                            await reclamation.reference.delete(); // Delete reclamation
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reclamation deleted successfully')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to delete reclamation')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.info, color: Colors.green),
                        onPressed: () {
                          // Navigate to reclamation details for this reclamation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReclamationDetailsScreen(reclamation: reclamation),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to reclamation form
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReclamationForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
