import 'package:flutter/material.dart';
import '../../models/reservation.dart';
import '../../models/hotel.dart';
import '../../services/Hotel/reservation_service.dart';
import 'hotel_app_theme.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final Hotel hotel;

  BookingPage({required this.hotel});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int roomCount = 1;
  int adultCount = 1;
  int childCount = 0;
  final reservationService = ReservationService();

  // Calculate total price based on selected options
  double get totalPrice {
    int nights = (checkOutDate?.difference(checkInDate!).inDays ?? 0);
    return nights > 0 ? nights * roomCount * widget.hotel.perNight : 0.0;
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (checkInDate ?? DateTime.now())
          : (checkOutDate ?? DateTime.now().add(Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
        } else {
          if (picked.isAfter(checkInDate ?? picked)) {
            checkOutDate = picked;
          } else {
            // Show an alert if check-out date is before check-in date
            _showErrorDialog('Check-out date must be after check-in date.');
          }
        }
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmBooking() async {
    // Log the booking details
    print('Booking Details:');
    print('Hotel: ${widget.hotel.titleTxt}');
    print('Check-in: ${checkInDate?.toLocal()}');
    print('Check-out: ${checkOutDate?.toLocal()}');
    print('Rooms: $roomCount');
    print('Adults: $adultCount');
    print('Children: $childCount');
    print('Total Price: \$${totalPrice.toStringAsFixed(2)}');

    Reservation newReservation = Reservation(
        hotelId: widget.hotel.id,
        userId: "1",
        startDate: checkInDate!.toLocal(),
        endDate: checkOutDate!.toLocal(),
        numberOfRooms: roomCount,
        adults: adultCount,
        kids: childCount,
        total: totalPrice);

    await reservationService.createReservation(newReservation);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.hotel.titleTxt}'),
        backgroundColor: HotelAppTheme.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Details
            Text(
              widget.hotel.titleTxt,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Location: ${widget.hotel.subTxt}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            // Date Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          checkInDate == null
                              ? 'Select Check-in Date'
                              : 'Check-in: ${DateFormat('yyyy-MM-dd').format(checkInDate!)}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          checkOutDate == null
                              ? 'Select Check-out Date'
                              : 'Check-out: ${DateFormat('yyyy-MM-dd').format(checkOutDate!)}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Nights Count Display
            if (checkInDate != null && checkOutDate != null)
              Text(
                'Total Nights: ${(checkOutDate!.difference(checkInDate!).inDays)}',
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 10),

            // Room and Guest Count
            Text('Rooms:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (roomCount > 1) setState(() => roomCount--);
                  },
                ),
                Text('$roomCount', style: TextStyle(fontSize: 20)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() => roomCount++);
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            Text('Adults:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (adultCount > 1) setState(() => adultCount--);
                  },
                ),
                Text('$adultCount', style: TextStyle(fontSize: 20)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() => adultCount++);
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            Text('Children:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (childCount > 0) setState(() => childCount--);
                  },
                ),
                Text('$childCount', style: TextStyle(fontSize: 20)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() => childCount++);
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // Total Price Display
            Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Spacer(), // Push the button to the bottom
            ElevatedButton(
              onPressed: _confirmBooking,
              child: Text('Confirm Booking'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                //primary: HotelAppTheme.dark_grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
