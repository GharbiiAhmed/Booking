import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReclamationForm extends StatelessWidget {
  const ReclamationForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController reclamationController = TextEditingController();

    // Function to show the thank you dialog
    void showThankYouDialog() {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing by tapping outside
        builder: (context) {
          return AlertDialog(
            title: const Text('Thank You!'),
            content: const Text(
              'Thank you for your feedback! An admin will be in touch with you soon.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context); // Go back to the previous screen
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
            title: const Text('Submission Failed!'),
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
        title: const Text('Add Reclamation'),
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

            // Submit button
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    reclamationController.text.isNotEmpty) {
                  try {
                    // Save reclamation to Firestore
                    await FirebaseFirestore.instance.collection('reclamations').add({
                      'username': usernameController.text,
                      'email': emailController.text,
                      'details': reclamationController.text,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    // Show the thank you dialog if submission is successful
                    showThankYouDialog();
                  } catch (e) {
                    // If an error occurs, show the failure dialog
                    showFailureDialog();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
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
