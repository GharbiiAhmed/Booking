import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<List<double>>> getCoordinatesFromLocations(List<String> locations, String accessToken) async {
  List<List<double>> coordinatesList = [];

  for (var location in locations) {
    // Make the geocoding API request
    final uri = Uri.https('api.mapbox.com', '/geocoding/v5/mapbox.places/${Uri.encodeComponent(location)}.json', {
      'access_token': accessToken,
      'limit': '1', // Limit to one result for simplicity
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['features'].isNotEmpty) {
        // Extract latitude and longitude
        double lat = data['features'][0]['geometry']['coordinates'][1];
        double lng = data['features'][0]['geometry']['coordinates'][0];
        coordinatesList.add([lat, lng]);
      } else {
        throw Exception('No results found for $location');
      }
    } else {
      throw Exception('Failed to load coordinates for $location');
    }
  }

  return coordinatesList;
}

/*void main() async {
  // Replace with your actual Mapbox Access Token
  String accessToken = 'YOUR_MAPBOX_ACCESS_TOKEN';

  List<String> locations = ['New York, USA', 'Los Angeles, USA'];

  try {
    List<List<double>> coords = await getCoordinatesFromLocations(locations, accessToken);
    for (var i = 0; i < locations.length; i++) {
      print('Coordinates for ${locations[i]}: ${coords[i][0]}, ${coords[i][1]}');
    }
  } catch (e) {
    print(e);
  }
}*/
