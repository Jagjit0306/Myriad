import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SosPage extends StatelessWidget {
  const SosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Builder(
              builder: (context) {
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final assetPath = isDarkMode
                    ? 'assets/logo_dark.svg'
                    : 'assets/logo_light.svg';
                return SvgPicture.asset(
                  assetPath,
                  height: 50,
                  placeholderBuilder: (BuildContext context) => Container(
                    height: 50,
                    width: 50,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  semanticsLabel: 'Logo',
                );
              },
            ),
            const SizedBox(width: 10),
            Text(
              "x",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 28,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.notification_important,
              color: Theme.of(context).colorScheme.inversePrimary,
              size: 50,
            ),
            const SizedBox(width: 70),
          ],
        ),
      ),
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
                            context, "Hospital", Icons.local_hospital, "26m"),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 130,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildDistanceCard(context, "Fire\nStation",
                            Icons.local_fire_department, "26m"),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 130,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildDistanceCard(context, "Police\nStation",
                            Icons.local_police, "26m"),
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
                    _buildEmergencyOption(
                        context, "Fire Station", Icons.local_fire_department),
                    _buildEmergencyOption(
                        context, "Access Wheels", Icons.location_on),
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
    return Container(
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
    );
  }

  Widget _buildEmergencyOption(
      BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () async {
        if (title == "Guardian") {
          String? guardianNumber = await _fetchGuardianNumber();
          if (guardianNumber != null) {
            _launchDialer(guardianNumber);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Guardian number not found.')),
            );
          }
        } else if (title == "SOS") {
          _launchDialer("112");
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

  Future<String?> _fetchGuardianNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('guardianPhone');
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
      await _audioPlayer
          .stop(); // Stop any previous playback to avoid conflicts
      await _audioPlayer.setSource(AssetSource('scream.mp3'));
      await _audioPlayer.setVolume(1.0);
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
