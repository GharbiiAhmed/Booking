class Driver {
  final String driverId;
  final String name;
  final String licenseNumber;
  final String status;
  final String description;
  final String profileImageUrl;

  Driver({
    required this.driverId,
    required this.name,
    required this.licenseNumber,
    required this.status,
    required this.description,
    required this.profileImageUrl,
  });

  factory Driver.fromMap(Map<String, dynamic> data) {
    return Driver(
      driverId: data['driverId'] ?? '',
      name: data['name'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      status: data['status'] ?? '',
      description: data['description'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'name': name,
      'licenseNumber': licenseNumber,
      'status': status,
      'description': description,
      'profileImageUrl': profileImageUrl,
    };
  }
}
