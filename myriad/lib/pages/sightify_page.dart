import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:myriad/components/banner_1.dart';
import 'package:myriad/components/round_button.dart';
import 'package:camera/camera.dart';

class SightifyPage extends StatefulWidget {
  const SightifyPage({super.key});

  @override
  State<SightifyPage> createState() => _SightifyPageState();
}

class _SightifyPageState extends State<SightifyPage> {
  final FlutterTts _flutterTts = FlutterTts();
  File? _imageFile;
  CameraController? _controller;
  bool _isTakingPicture = false;
  final Gemini gemini = Gemini.instance;

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> _takeInstantPicture() async {
    if (_isTakingPicture) return;

    setState(() {
      _isTakingPicture = true;
    });

    try {
      // Initialize cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Create and initialize the controller
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      // Take picture immediately
      final XFile photo = await _controller!.takePicture();

      setState(() {
        _imageFile = File(photo.path);
        askGemini();
      });
      //TODO: trigger gemini
    } catch (e) {
      print('Error taking picture: $e');
    } finally {
      // Clean up
      await _controller?.dispose();
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  void askGemini() {
    gemini.textAndImage(
      text:
          "Describe what you see in this picture to a person with visual impairment",
      images: [_imageFile!.readAsBytesSync()],
    ).then(
      (value) {
        final dataContent = jsonDecode(jsonEncode(value!.content!.parts![0]))
            as Map<String, dynamic>;
        _speak(dataContent['text'] ?? "Error encountered !");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sightify"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_imageFile == null)
            Banner1(
              bannerIcon: Icons.visibility,
              tilt: 3.14 / 2,
            ),
          if (_imageFile != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 3,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(27),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoundButton(
                icon: Icons.camera_alt,
                onPressed: (_isTakingPicture) ? () {} : _takeInstantPicture,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
