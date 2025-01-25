import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';

class SosPage extends StatelessWidget {
  const SosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 20),
            SvgPicture.asset(
              'assets/logo.svg',
              height: 80,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
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

                // Emergency services distance indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        height: 130,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildDistanceCard(context, "Hospital", Icons.local_hospital, "26m"),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 130,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildDistanceCard(context, "Fire\nStation", Icons.local_fire_department, "26m"),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 130,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildDistanceCard(context, "Police\nStation", Icons.local_police, "26m"),
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
                    _buildEmergencyOption(context, "Ambulance", Icons.medical_services),
                    _buildEmergencyOption(context, "Fire Station", Icons.local_fire_department),
                    _buildEmergencyOption(context, "Access Wheels", Icons.location_on),
                    _buildEmergencyOption(context, "Guardian", Icons.phone),
                    _buildEmergencyOption(context, "SOS", Icons.notification_important),
                    _buildEmergencyOption(context, "Scream", Icons.campaign, onTap: _playScreamSound),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _playScreamSound() async {
    final AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.setSource(AssetSource('assets/scream.mp3'));
    await audioPlayer.setVolume(1.0);
    await audioPlayer.resume();
  }

  Widget _buildDistanceCard(BuildContext context, String title, IconData icon, String distance) {
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

  Widget _buildEmergencyOption(BuildContext context, String title, IconData icon, {Function? onTap}) {
    return GestureDetector(
      onTap: () {
        if (title == "SOS") {
          _launchDialer("112");
        } else if (title == "Scream") {
          onTap?.call();
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
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
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