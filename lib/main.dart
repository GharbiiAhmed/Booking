import 'package:flutter/material.dart';
import 'screens/hotel_search_page.dart'; // Assurez-vous que ce chemin est correct

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TravelApp(),
  ));
}

class TravelApp extends StatefulWidget {
  @override
  _TravelAppState createState() => _TravelAppState();
}

class _TravelAppState extends State<TravelApp> {
  // Liste des chemins des images dans le dossier assets
  List<String> assetUrls = [
    "assets/images/image1.jpg",
    "assets/images/image2.jpg",
    "assets/images/image3.jpg",
    "assets/images/image4.jpg",
    "assets/images/image5.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Ajout d'un dégradé comme fond
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6B8E23), // Couleur de début
              Color(0xFF3CB371), // Couleur de fin
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0), // Ajustement du padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.0), // Ajout d'un espace au-dessus du texte
              Text(
                "Find Your Perfect Stay with Ease!",
                style: TextStyle(
                  color: Colors.white, // Changement de la couleur du texte
                  fontSize: 26.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Pick your destination",
                style: TextStyle(
                  color: Colors.white, // Changement de la couleur du texte
                  fontSize: 20.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 20.0),
              Material(
                elevation: 10.0,
                borderRadius: BorderRadius.circular(30.0),
                shadowColor: Color(0x55434343),
                child: TextField(
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: "Search for Hotel, Flight...",
                    hintStyle: TextStyle(color: Colors.black54), // Couleur de l'index
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.black54,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              DefaultTabController(
                length: 3,
                child: Expanded(
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: Color(0xFFFE8C68),
                        unselectedLabelColor: Color(0xFF555555),
                        labelColor: Color(0xFFFE8C68),
                        labelPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        tabs: [
                          Tab(text: "Trending"),
                          Tab(text: "Promotion"),
                          Tab(text: "Favorites"),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        height: 300.0,
                        child: TabBarView(
                          children: [
                            ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                travelCard(assetUrls[0], "Luxury Hotel", "Caroline", 3),
                                travelCard(assetUrls[1], "Plaza Hotel", "Italy", 4),
                                travelCard(assetUrls[4], "Safari Hotel", "Africa", 5),
                              ],
                            ),
                            ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                travelCard(assetUrls[3], "Visit Rome", "Italy", 4),
                                travelCard(assetUrls[2], "Visit Sidi Bou Said", "Tunisia", 4),
                              ],
                            ),
                            ListView(
                              scrollDirection: Axis.horizontal,
                              children: [],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Bouton pour naviguer vers la page de recherche d'hôtel
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HotelSearchPage()),
                          );
                        },
                        child: Text("Search for Hotels"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Color(0xFFB7B7B7),
        selectedItemColor: Color(0xFFFE8C68),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "Bookmark",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Destination",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notification",
          ),
        ],
      ),
    );
  }
}

// Exemple de fonction `travelCard`
Widget travelCard(String imageUrl, String hotelName, String location, int rating) {
  return Container(
    width: 200.0,
    margin: EdgeInsets.only(right: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset(imageUrl, fit: BoxFit.cover, width: 200.0, height: 150.0),
        ),
        SizedBox(height: 10.0),
        Text(
          hotelName,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.white), // Changement de couleur
        ),
        Text(location, style: TextStyle(color: Colors.white)), // Changement de couleur
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 16.0,
            );
          }),
        ),
      ],
    ),
  );
}
