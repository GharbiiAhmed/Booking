class User {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String role;

  // Private static instance
  static User? _instance;

  // Private constructor
  User._({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.role,
  });

  // Factory constructor to get the singleton instance
  factory User({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) {
    // If instance is null, create one and store it
    if (_instance == null) {
      _instance = User._(
        userId: userId,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        role: role,
      );
    }
    // Return the instance (singleton)
    return _instance!;
  }

  // Method to get the singleton instance
  static User getInstance() {
    if (_instance == null) {
      throw Exception("User instance is not initialized. Please login first.");
    }
    return _instance!;
  }

  // Method to initialize or set user data
  static void setUserData({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) {
    _instance = User._(
      userId: userId,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      role: role,
    );
  }

  // Method to authenticate user by checking password
  bool authenticate(String inputPassword) {
    return inputPassword == password;
  }

  // Method to clear the user data (e.g., for logout)
  static void clearUserData() {
    _instance = null;
  }

  // Convert user data to a Map (for Firebase or other purposes)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'role': role,
    };
  }

  // Factory constructor to create a user from a Map
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      password: data['password'] ?? '',
      role: data['role'] ?? '',
    );
  }
}
