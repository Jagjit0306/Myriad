import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
// import 'package:intl/intl.dart';
import 'package:myriad/passwords.dart';
import 'package:http/http.dart' as http;
// import 'package:syncfusion_flutter_charts/charts.dart' as charts;

class MapsWheelchairHomePage extends StatefulWidget {
  const MapsWheelchairHomePage({super.key});

  @override
  State<MapsWheelchairHomePage> createState() => _MapsWheelchairHomePageState();
}

class _MapsWheelchairHomePageState extends State<MapsWheelchairHomePage> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(45.521563, -122.677433); // Default location
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: MAPS_API_KEY);
  // Set<Marker> _markers = {}; // Dynamic marker set

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

  void bottomModal(BuildContext context, PlacesSearchResult place) {
    showModalBottomSheet(
      context: context,
      barrierColor: const Color.fromARGB(134, 0, 0, 0),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 25,
                children: [
                  const Text(
                    "Accessibility Menu",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      Text(
                        place.name,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (place.rating != null)
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [Text('${place.rating}'), Icon(Icons.star)],
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      WheelchairRequestSection(
                        placeId: place.placeId,
                        places: _places,
                      ),
                    ],
                  ),
                ],
              ),
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
                      bottomModal(context, eachPlace);
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
        centerTitle: true,
        title: const Text('Wheelify'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        // markers: _markers,
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
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.placeId}&fields=name%2Crating%2Cwheelchair_accessible_entrance&key=$MAPS_API_KEY");
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

  // @override
  Widget _build(BuildContext context) {
    return Column(
      children: [
        (!sent)
            ? Column(
                children: [
                  const Text(
                    "This place is not wheelchair accessible, but you can request facilities, to ease your experience at this location.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: GestureDetector(
                      onTap: () {
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
                      child: Card(
                        elevation: 5,
                        color: Colors.yellow.shade800,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Request Wheelchair\nAccessibility",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade200,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Icon(
                                Icons.accessible,
                                color: Colors.grey.shade200,
                                size: 35,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  const Text(
                    "Your wheelchair accessibility request has been submitted. Special arrangments will be made for you at your specified date for your convenience.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Card(
                      elevation: 5,
                      color: Colors.blue[800],
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Wheelchair request sent",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade200,
                              ),
                            ),
                            Icon(
                              Icons.check,
                              color: Colors.grey.shade200,
                              size: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        (wheelChairAccessible == true)
            ? Column(
                children: [
                  const Text(
                    "This place is wheelchair accessible.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Card(
                      elevation: 5,
                      color: Colors.green.shade900,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Wheelchair Accessible",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade200,
                              ),
                            ),
                            Icon(
                              Icons.accessible,
                              color: Colors.grey.shade200,
                              size: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _build(context),
      ],
    );
  }
}

// Highly bugged and
// Places API isnt giving proper timing data for some reason
// class _WorkingHoursChart extends StatelessWidget {
//   final PlacesSearchResult place;

//   _WorkingHoursChart({required this.place});

//   @override
//   Widget build(BuildContext context) {
//     log("DATA WE GET");
//     log(jsonEncode(place));
//     List<String> openingHours = place.openingHours?.weekdayText ?? [];
//     List<WorkingHoursData> chartData = parseOpeningHours(openingHours);
//     print(
//         "Chart Data: ${chartData.map((e) => "${e.day}: ${e.open} - ${e.close}")}");

//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: charts.SfCartesianChart(
//         primaryXAxis: charts.CategoryAxis(),
//         primaryYAxis: charts.NumericAxis(
//           title: charts.AxisTitle(text: 'Hours (24-hour format)'),
//           minimum: 0,
//           maximum: 24,
//           interval: 4,
//         ),
//         title: charts.ChartTitle(text: 'Opening & Closing Hours'),
//         tooltipBehavior: charts.TooltipBehavior(enable: true),
//         series: <charts.CartesianSeries>[
//           charts.RangeColumnSeries<WorkingHoursData, String>(
//             dataSource: chartData,
//             xValueMapper: (WorkingHoursData data, _) => data.day,
//             lowValueMapper: (WorkingHoursData data, _) => data.open,
//             highValueMapper: (WorkingHoursData data, _) => data.close,
//             name: 'Working Hours',
//             color: Colors.blue,
//             dataLabelSettings: charts.DataLabelSettings(isVisible: true),
//           ),
//         ],
//       ),
//     );
//   }

//   List<WorkingHoursData> parseOpeningHours(List<String> hours) {
//     List<WorkingHoursData> parsedHours = [];

//     for (String day in hours) {
//       print("Parsing: $day"); // Debugging line
//       List<String> parts = day.split(": ");
//       if (parts.length < 2) {
//         print("Skipping invalid format: $day");
//         continue;
//       }

//       String dayName = parts[0];
//       String timing = parts[1];

//       if (timing.toLowerCase() == "closed") {
//         parsedHours.add(WorkingHoursData(dayName, 0, 0));
//         continue;
//       }

//       List<String> timeParts = timing.split(" – ");
//       if (timeParts.length < 2) {
//         print("Skipping invalid time: $timing");
//         continue;
//       }

//       DateTime openTime = _parseTime(timeParts[0]);
//       DateTime closeTime = _parseTime(timeParts[1]);

//       print(
//           "Parsed: $dayName -> Open: ${openTime.hour}, Close: ${closeTime.hour}");

//       parsedHours.add(WorkingHoursData(
//           dayName, openTime.hour.toDouble(), closeTime.hour.toDouble()));
//     }
//     print("Final Parsed Data: $parsedHours");
//     return parsedHours;
//   }

//   DateTime _parseTime(String timeStr) {
//     return DateFormat.jm().parse(timeStr);
//   }
// }

// class WorkingHoursData {
//   final String day;
//   final double open;
//   final double close;

//   WorkingHoursData(this.day, this.open, this.close);
// }
