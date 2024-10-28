class Vehicle {
  final String vehicleId;
  final String plateNumber;
  final String type;
  final String status;
  final String model;
  final String imageUrl;

  Vehicle({
    required this.vehicleId,
    required this.plateNumber,
    required this.type,
    required this.status,
    required this.model,
    required this.imageUrl,
  });

  factory Vehicle.fromMap(Map<String, dynamic> data) {
    return Vehicle(
      vehicleId: data['vehicleId'] ?? '',
      plateNumber: data['plateNumber'] ?? '',
      type: data['type'] ?? '',
      status: data['status'] ?? '',
      model: data['model'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'plateNumber': plateNumber,
      'type': type,
      'status': status,
      'model': model,
      'imageUrl': imageUrl,
    };
  }
}
