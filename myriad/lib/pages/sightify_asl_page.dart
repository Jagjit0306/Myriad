import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:myriad/components/banner_1.dart';
import 'package:myriad/components/round_button.dart';
import 'package:camera/camera.dart';
import 'package:myriad/pages/sightify_page.dart';

class SightifyASLPage extends StatefulWidget {
  const SightifyASLPage({super.key});

  @override
  State<SightifyASLPage> createState() => _SightifyASLPageState();
}

class _SightifyASLPageState extends State<SightifyASLPage>
    with WidgetsBindingObserver {
  File? _imageFile;
  CameraController? _controller;
  bool _isTakingPicture = false;
  final Gemini gemini = Gemini.instance;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takeInstantPicture() async {
    if (_isTakingPicture) return;

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      final XFile photo = await _controller!.takePicture();

      setState(() {
        _imageFile = File(photo.path);
        askGemini();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: $e')),
        );
      }
    } finally {
      await _controller?.dispose();
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  void askGemini() {
    gemini.textAndImage(
      text: "Identify and interpret any sign language gestures in this image. If you see ASL (American Sign Language) gestures, tell me what they mean. Keep the response concise. VERY CONCISE, AROUND 5 WORDS",
      images: [_imageFile!.readAsBytesSync()],
    ).then(
      (value) {
        final dataContent = jsonDecode(jsonEncode(value!.content!.parts![0]))
            as Map<String, dynamic>;
        _showResponseDialog(dataContent['text'] ?? "Error encountered!");
      },
    ).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("We cannot reach our service right now")),
        );
      }
    });
  }

  void _showResponseDialog(String response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Translation'),
        content: Text(response),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Language Interpreter"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_imageFile == null)
            Banner1(
              bannerIcon: Icons.sign_language,
              tilt: 3.14 / 2,
            ),
          if (_imageFile != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: GestureDetector(
                  key: _key,
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 3,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
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
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundButton(
                  iconColor: Theme.of(context).colorScheme.inversePrimary,
                  icon: Icons.camera_alt,
                  onPressed: (_isTakingPicture) ? () {} : _takeInstantPicture,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 