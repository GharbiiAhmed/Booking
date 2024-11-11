import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/hotel.dart';
import 'booking_page.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotelData;

  const HotelDetailsScreen({Key? key, required this.hotelData}) : super(key: key);

  @override
  _HotelDetailsScreenState createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  late Future<String?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _getFirebaseImage(widget.hotelData.imagePath);
  }

  
  Future<String?> _getFirebaseImage(String imagePath) async {
    if (imagePath.isEmpty) return null;
    try {
      final ref = FirebaseStorage.instance.ref().child(imagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error fetching Firebase image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotelData.titleTxt),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Cover Image with Fallback
              FutureBuilder<String?>(
                future: _imageFuture,
                builder: (context, snapshot) {
                  return Container(
                    height: 250,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: snapshot.hasData && snapshot.data != null
                            ? NetworkImage(snapshot.data!)
                            : AssetImage('assets/fallback_image.png') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(16),

                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Hotel Details Card
              Card(
                elevation: 6,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hotelData.titleTxt,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: ${widget.hotelData.subTxt}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            '${widget.hotelData.dist.toStringAsFixed(1)} km to city',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.green, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            '\$${widget.hotelData.perNight}/night',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orangeAccent, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            '${widget.hotelData.rating} ⭐',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${widget.hotelData.reviews} Reviews',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingPage(hotel: widget.hotelData),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Mini Map with Navigation to Google Maps
              const SizedBox(height: 20),
              Text(
                'Hotel Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(widget.hotelData.latitude, widget.hotelData.longitude),
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(widget.hotelData.latitude, widget.hotelData.longitude),
                          child: IconButton(
                            icon: Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                            onPressed: () async {
                              final url =
                                  'https://www.google.com/maps/dir/?api=1&destination=${widget.hotelData.latitude},${widget.hotelData.longitude}';
                              if (await canLaunch(url)) {
                                await launch(url);
                              }
                            },
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
    );
  }
}
