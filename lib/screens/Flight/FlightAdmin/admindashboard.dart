import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/FlightFirebase/firebase_service.dart';
import 'adminaddflight.dart';
import 'adminupdateflight.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to Add Flight screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateFlightScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: firebaseService.readFlights(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No flights available."));
                }
                final flights = snapshot.data!;
                return ListView.builder(
                  itemCount: flights.length,
                  itemBuilder: (context, index) {
                    final flight = flights[index];
                    return ListTile(
                      title: Text("Flight: ${flight['flightNumber']}"),
                      subtitle: Text("${flight['airline']} - ${flight['price']} USD"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Navigate to Update Flight screen with flight data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateFlightScreen(
                                    flightId: flight['id'],
                                    initialFlightData: flight,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              // Show confirmation dialog before deleting
                              bool confirm = await _showConfirmationDialog(context);
                              if (confirm) {
                                await firebaseService.deleteFlight(flight['id']);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(), // To separate flights and reclamations
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Reclamations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reclamations').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading reclamations'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No reclamations found.'));
                }

                final reclamations = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: reclamations.length,
                  itemBuilder: (context, index) {
                    final reclamation = reclamations[index];
                    final reclamationData = reclamation.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text('Reclamation: ${reclamationData['details']}'),
                      subtitle: Text('Created At: ${reclamationData['createdAt']?.toDate()}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // Show confirmation dialog before deleting
                          bool confirm = await _showConfirmationDialog(context);
                          if (confirm) {
                            try {
                              await reclamation.reference.delete(); // Delete reclamation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Reclamation deleted successfully')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to delete reclamation')),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}
