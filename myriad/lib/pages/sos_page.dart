import 'package:flutter/material.dart';
import 'package:myriad/components/my_app_bar.dart';
import 'package:myriad/database/user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:myriad/passwords.dart';
import 'package:map_launcher/map_launcher.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  final UserDatabase userDatabase = UserDatabase();

  String guardianNumber = "";
  Position? _currentPosition;
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: MAPS_API_KEY);
  Map<String, PlaceDetails?> emergencyServices = {
    'Hospital': null,
    'Fire Station': null,
    'Police Station': null,
  };
  Map<String, double> distances = {
    'Hospital': double.infinity,
    'Fire Station': double.infinity,
    'Police Station': double.infinity,
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getGuardianNumber();
  }

  Future<void> _getGuardianNumber() async {
    String? temp = await userDatabase.getGuardianNumber();
    if (temp!.isNotEmpty) {
      setState(() {
        guardianNumber = temp;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
        _findNearbyEmergencyServices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> _findNearbyEmergencyServices() async {
    if (_currentPosition == null) return;

    final location = Location(
      lat: _currentPosition!.latitude,
      lng: _currentPosition!.longitude,
    );

    try {
      // Search for hospitals
      final hospitalsResponse = await _places.searchNearbyWithRankBy(
        location,
        "distance",
        type: "hospital",
        keyword: "hospital",
      );

      // Search for fire stations
      final fireStationsResponse = await _places.searchNearbyWithRankBy(
        location,
        "distance",
        type: "fire_station",
        keyword: "fire station",
      );

      // Search for police stations
      final policeStationsResponse = await _places.searchNearbyWithRankBy(
        location,
        "distance",
        type: "police",
        keyword: "police station",
      );

      if (mounted) {
        setState(() {
          if (hospitalsResponse.results.isNotEmpty) {
            _getPlaceDetails(
                hospitalsResponse.results.first.placeId, 'Hospital');
            distances['Hospital'] = _calculateDistance(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              hospitalsResponse.results.first.geometry!.location.lat,
              hospitalsResponse.results.first.geometry!.location.lng,
            );
          }

          if (fireStationsResponse.results.isNotEmpty) {
            _getPlaceDetails(
                fireStationsResponse.results.first.placeId, 'Fire Station');
            distances['Fire Station'] = _calculateDistance(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              fireStationsResponse.results.first.geometry!.location.lat,
              fireStationsResponse.results.first.geometry!.location.lng,
            );
          }

          if (policeStationsResponse.results.isNotEmpty) {
            _getPlaceDetails(
                policeStationsResponse.results.first.placeId, 'Police Station');
            distances['Police Station'] = _calculateDistance(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              policeStationsResponse.results.first.geometry!.location.lat,
              policeStationsResponse.results.first.geometry!.location.lng,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding emergency services: $e')),
        );
      }
    }
  }

  Future<void> _getPlaceDetails(String placeId, String serviceType) async {
    try {
      final response = await _places.getDetailsByPlaceId(placeId);
      if (mounted && response.status == "OK") {
        setState(() {
          emergencyServices[serviceType] = response.result;
        });
      }
    } catch (e) {
      print('Error getting place details: $e');
    }
  }

  Future<void> _openMapsWithDestination(String serviceType) async {
    if (_currentPosition == null || emergencyServices[serviceType] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location information not available yet.')),
      );
      return;
    }

    final place = emergencyServices[serviceType]!;
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No map apps found on device.')),
      );
      return;
    }

    if (availableMaps.length == 1) {
      await availableMaps.first.showDirections(
        destination: Coords(
          place.geometry!.location.lat,
          place.geometry!.location.lng,
        ),
        destinationTitle: place.name,
        origin: Coords(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Open with:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ...availableMaps.map(
                    (map) => ListTile(
                      onTap: () {
                        map.showDirections(
                          destination: Coords(
                            place.geometry!.location.lat,
                            place.geometry!.location.lng,
                          ),
                          destinationTitle: place.name,
                          origin: Coords(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      title: Text(map.mapName),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  double _calculateDistance(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  String _formatDistance(double distance) {
    if (distance == double.infinity) return "...";
    if (distance < 1000) {
      return "${distance.round()}m";
    } else {
      return "${(distance / 1000).toStringAsFixed(1)}km";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: MyAppBar(title: 'SOS'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        height: 130,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildDistanceCard(
                          context,
                          "Hospital",
                          Icons.local_hospital,
                          _formatDistance(distances['Hospital']!),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 130,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildDistanceCard(
                          context,
                          "Fire\nStation",
                          Icons.local_fire_department,
                          _formatDistance(distances['Fire Station']!),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 130,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildDistanceCard(
                          context,
                          "Police\nStation",
                          Icons.local_police,
                          _formatDistance(distances['Police Station']!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    _buildEmergencyOption(
                        context, "Ambulance", Icons.medical_services),
                    _buildEmergencyOption(context, "Guardian", Icons.phone),
                    _buildEmergencyOption(
                        context, "SOS", Icons.notification_important),
                    _ScreamButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceCard(
      BuildContext context, String title, IconData icon, String distance) {
    String serviceType = title.replaceAll('\n', ' ').trim();

    return GestureDetector(
      onTap: () => _openMapsWithDestination(serviceType),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.inversePrimary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.inversePrimary,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              distance,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyOption(
      BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () async {
        if (title == "Guardian") {
          if (guardianNumber.isNotEmpty) {
            _launchDialer(guardianNumber);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Guardian number not found.')),
            );
          }
        } else if (title == "SOS") {
          _launchDialer("112");
        } else if (title == "Ambulance") {
          _launchDialer("102");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                icon,
                color: Theme.of(context).colorScheme.surface,
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchDialer(String number) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number,
    );
    await launchUrl(launchUri);
  }
}

class _ScreamButton extends StatefulWidget {
  @override
  State<_ScreamButton> createState() => _ScreamButtonState();
}

class _ScreamButtonState extends State<_ScreamButton> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleScreamSound,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Scream",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.campaign,
                color: Theme.of(context).colorScheme.surface,
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleScreamSound() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.setSource(AssetSource('scream.mp3'));
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.resume();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
