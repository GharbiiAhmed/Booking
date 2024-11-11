import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReclamationEditForm extends StatelessWidget {
  final DocumentSnapshot reclamation;

  ReclamationEditForm({required this.reclamation});

  @override
  Widget build(BuildContext context) {
    final reclamationData = reclamation.data() as Map<String, dynamic>;
    final TextEditingController usernameController = TextEditingController(text: reclamationData['username']);
    final TextEditingController emailController = TextEditingController(text: reclamationData['email']);
    final TextEditingController reclamationController = TextEditingController(text: reclamationData['details']);

    // Function to show the success dialog
    void showSuccessDialog() {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing by tapping outside
        builder: (context) {
          return AlertDialog(
            title: const Text('Reclamation Updated!'),
            content: const Text(
              'Your reclamation has been updated successfully!',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the success dialog
                  Navigator.pop(context); // Go back to the previous screen (ReclamationDetailsScreen)
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    // Function to show the failure dialog
    void showFailureDialog() {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing by tapping outside
        builder: (context) {
          return AlertDialog(
            title: const Text('Update Failed!'),
            content: const Text(
              'Something went wrong. Please try again later.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the failure dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Reclamation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Username field
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 10),

            // Email field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            // Reclamation details field
            TextField(
              controller: reclamationController,
              decoration: const InputDecoration(labelText: 'Reclamation Details'),
            ),
            const SizedBox(height: 20),

            // Update button
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    reclamationController.text.isNotEmpty) {
                  try {
                    // Update reclamation in Firestore
                    await reclamation.reference.update({
                      'username': usernameController.text,
                      'email': emailController.text,
                      'details': reclamationController.text,
                    });

                    // Show the success dialog
                    showSuccessDialog();
                  } catch (e) {
                    // In case of failure, show failure dialog
                    showFailureDialog();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
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
