import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taxi_reservation/hotel_booking/pages/hotel_details.dart';
import '../models/hotel.dart';
import 'hotel_app_theme.dart';

class HotelListView extends StatelessWidget {
  const HotelListView({
    Key? key,
    required this.hotelData,
    this.animationController,
    this.animation,
    this.callback,
  }) : super(key: key);

  final VoidCallback? callback;
  final Hotel hotelData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HotelDetailsScreen(hotelData: hotelData),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      offset: Offset(4, 4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Column(
                    children: [
                      // Use the appropriate image widget based on the image path type
                      hotelData.imagePath.startsWith('http')
                          ? AspectRatio(
                        aspectRatio: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FadeInImage(
                            placeholder: AssetImage('assets/fallback_image.png'),
                            image: NetworkImage(hotelData.imagePath),
                            fit: BoxFit.cover,
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/fallback_image.png', // Fallback in case of error
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      )
                          : AspectRatio(
                        aspectRatio: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            hotelData.imagePath, // Path to image in the assets folder
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      Container(
                        color: HotelAppTheme.buildLightTheme().canvasColor,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hotelData.titleTxt,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 22,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        hotelData.subTxt,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.withOpacity(0.8),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        FontAwesomeIcons.locationDot,
                                        size: 12,
                                        color: HotelAppTheme.buildLightTheme().primaryColor,
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${hotelData.dist.toStringAsFixed(1)} km to city',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      RatingBarIndicator(
                                        rating: hotelData.rating,
                                        itemBuilder: (context, index) => Icon(
                                          Icons.star,
                                          color: HotelAppTheme.buildLightTheme().primaryColor,
                                        ),
                                        itemCount: 5,
                                        itemSize: 24,
                                        direction: Axis.horizontal,
                                      ),
                                      SizedBox(width: 0.8),
                                      Text(
                                        '${hotelData.reviews} Reviews',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${hotelData.perNight}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  '/per night',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
