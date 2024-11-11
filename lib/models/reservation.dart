
class Reservation {
  String? id;
  String hotelId;
  String userId;
  DateTime startDate;
  DateTime endDate;
  int numberOfRooms;
  int adults;
  int kids;
  double total;

  Reservation({
    this.id,
    required this.hotelId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.numberOfRooms,
    required this.adults,
    required this.kids,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'hotelId': hotelId,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'numberOfRooms': numberOfRooms,
      'adults': adults,
      'kids': kids,
      'total': total,
    };
  }

  static Reservation fromMap(String id, Map<String, dynamic> map) {
    return Reservation(
      id: id,
      hotelId: map['hotelId'],
      userId: map['userId'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      numberOfRooms: map['numberOfRooms'],
      adults: map['adults'],
      kids: map['kids'],
      total: map['total'],
    );
  }
}
