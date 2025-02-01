import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_image.dart';
import 'package:myriad/passwords.dart';
import 'package:http/http.dart' as http;

class MapsWheelchairHomePage extends StatefulWidget {
  const MapsWheelchairHomePage({super.key});

  @override
  State<MapsWheelchairHomePage> createState() => _MapsWheelchairHomePageState();
}

class _MapsWheelchairHomePageState extends State<MapsWheelchairHomePage> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(45.521563, -122.677433); // Default location
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: MAPS_API_KEY);
  Set<Marker> _markers = {}; // Dynamic marker set

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return;
    }

    // Fetch the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

  // TODO : untested
    if (!mounted) return;
    setState(() {
      _center =
          LatLng(position.latitude, position.longitude); // Update the center

      // Move the camera to the user's location
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_center, 14.0),
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void BottomModal(BuildContext context, PlacesSearchResult place) {
    showModalBottomSheet(
      context: context,
      barrierColor: const Color.fromARGB(134, 0, 0, 0),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  place.name,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                MyImage(imageUrl: place.icon ?? ""),
                if (place.rating != null)
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('${place.rating}'), Icon(Icons.star)],
                  ),
                WheelchairRequestSection(
                  placeId: place.placeId,
                  places: _places,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onTap(LatLng position) async {
    if (!mounted) return;
    final result = _places.searchNearbyWithRadius(
        Location(lat: position.latitude, lng: position.longitude), 20);

    result.then((placesResult) {
      if (!mounted) return;
      if (placesResult.results.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Choose Location'),
            content: SizedBox(
              width: 300,
              child: ListView.builder(
                itemCount: placesResult.results.length,
                itemBuilder: (context, index) {
                  final eachPlace = placesResult.results[index];
                  return ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      BottomModal(context, eachPlace);
                    },
                    title: Text(eachPlace.name),
                  );
                },
              ),
            ),
          ),
        );
      }
    }).catchError((e) {
      print('Error searching nearby places: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wheelify'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(target: _center, zoom: 11),
        onTap: _onTap,
      ),
    );
  }
}

class WheelchairRequestSection extends StatefulWidget {
  final String placeId;
  final GoogleMapsPlaces places;
  const WheelchairRequestSection(
      {super.key, required this.placeId, required this.places});

  @override
  State<WheelchairRequestSection> createState() =>
      _WheelchairRequestSectionState();
}

class _WheelchairRequestSectionState extends State<WheelchairRequestSection> {
  bool wheelChairAccessible = true;
  bool sent = false;

  @override
  void initState() {
    super.initState();
    _fetchPlaceData();
  }

  Future<http.Response> fetchRequestGET(String uri) async {
    return await http.get(Uri.parse(uri));
  }

  Future<void> _fetchPlaceData() async {
    try {
      final response = await fetchRequestGET(
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.placeId}&fields=name%2Crating%2Cwheelchair_accessible_entrance&key=${MAPS_API_KEY}");
      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;

        final Map<String, dynamic>? result =
            responseBody['result'] as Map<String, dynamic>?;

        setState(() {
          wheelChairAccessible =
              result?['wheelchair_accessible_entrance'] ?? false;
          // wheelChairAccessible =
          //     (result?.keys.contains("wheelchair_accessible_entrance") == true)
          //         ? (result?['wheelchair_accessible_entrance'])
          //         : false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget _build(BuildContext context) {
    return Column(
      children: [
        if (!sent)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                DateTime d = DateTime.now();
            
                // Calculate the last date by adding 1 month
                DateTime lastDate = DateTime(
                  d.year,
                  d.month + 1,
                  d.day,
                );
            
                // Adjust for day overflow (e.g., February might have fewer days)
                if (lastDate.month > (d.month + 1) % 12) {
                  lastDate = DateTime(lastDate.year, lastDate.month,
                      0); // Last day of the previous month
                }
            
                showDatePicker(
                  context: context,
                  initialDate: d,
                  firstDate: d, // Start from tomorrow
                  lastDate: lastDate,
                ).then(
                  (value) {
                    // Do something with that date
                    setState(() => sent = true);
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade700,
              ),
                child: Text(
                "Request Wheelchair Accessibility",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                ),
            ),
          ),
        if (sent)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              color: Theme.of(context).colorScheme.secondary,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: const Text(
                  "Wheelchair request sent !",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (wheelChairAccessible == true)
          Padding(
            padding: const EdgeInsets.fromLTRB(45, 10, 45, 10),
            child: Card(
              elevation: 5,
              color: Colors.green.shade900,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Wheelchair Accessible",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade200,
                      ),
                    ),
                    Icon(Icons.accessible, color: Colors.grey.shade200,),
                  ],
                ),
              ),
            ),
          ),
        if (wheelChairAccessible == false) _build(context),
      ],
    );
  }
}
