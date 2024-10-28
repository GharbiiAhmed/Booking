import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get users => _firestore.collection('Users');

  // Add a new user
  Future<void> addUser(String name, String email, String phoneNumber) async {
    await users.add({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    });
  }

  // Delete a user by ID
  Future<void> deleteUser(String userId) async {
    await users.doc(userId).delete();
  }

  // Update user details
  Future<void> updateUser(String userId, String name, String email, String phoneNumber) async {
    await users.doc(userId).update({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    });
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    QuerySnapshot snapshot = await users.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
