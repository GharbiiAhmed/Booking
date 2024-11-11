import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:taxi_reservation/screens/Flight/flightsearch.dart';

import '../hotel_booking/hotel_home_screen.dart';
import '../introduction_animation/introduction_animation_screen.dart';
import '../screens/Vehicle/booking_screen.dart';

class HomeList {
  HomeList({
    this.navigateScreen,
    this.imagePath = '',
  });
  Widget? navigateScreen;
  String imagePath;

  static List<HomeList> homeList = [
    HomeList(
      imagePath: 'assets/logos/car-rental.png',
      navigateScreen: BookingScreen(),
    ),
    HomeList(
      imagePath: 'assets/logos/hotel.png',
      navigateScreen: HotelHomeScreen(),
    ),
  
    HomeList(
      imagePath: 'assets/logos/plane-booking.png',
      navigateScreen: FlightSearchScreen(),
    ),
  ];
}
