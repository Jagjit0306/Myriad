import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:myriad/components/banner_1.dart';
import 'package:myriad/components/round_button.dart';
import 'package:camera/camera.dart';
// import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

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
  final GlobalKey _key = GlobalKey();

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
    print("ASKING GEMINI");
    // ignore: deprecated_member_use
    gemini.textAndImage(
      text:
          "Describe what you see in this picture to a person with visual impairment, keep it short",
      images: [_imageFile!.readAsBytesSync()],
    ).then(
      (value) {
        print("Response recieved");
        final dataContent = jsonDecode(jsonEncode(value!.content!.parts![0]))
            as Map<String, dynamic>;
        _speak(dataContent['text'] ?? "Error encountered !");
      },
    ).catchError((e) {
      print("GEMINI ERROR");
      print(e);
    });
  }

  // ignore: non_constant_identifier_names
  void askGemini_onTouch(File croppedImg) {
    // ignore: deprecated_member_use
    gemini.textAndImage(
      text: ("Very briefly decribe what you see exactly in the center"),
      images: [croppedImg.readAsBytesSync()],
    ).then(
      (value) {
        final dataContent = jsonDecode(jsonEncode(value!.content!.parts![0]))
            as Map<String, dynamic>;
        _speak(dataContent['text'] ?? "Error encountered !");
      },
    ).catchError((e) {
      print("GEMINI ERROR");
      print(e);
    });
  }

  Future<void> temp(double x, double y) async {
    final newimg = await cropImageWithRatios(
      imageFile: _imageFile!,
      xRatio: x,
      yRatio: y,
      widthRatio: 0.5,
      heightRatio: 0.5,
    );
    setState(() {
      _imageFile = newimg;
    });
  }

  Future<void> cropAndGemini(double x, double y) async {
    final newImg = await cropImageWithRatios(
      imageFile: _imageFile!,
      xRatio: x,
      yRatio: y,
      widthRatio: 0.3,
      heightRatio: 0.3,
    );
    askGemini_onTouch(newImg);
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
                child: GestureDetector(
                  key: _key,
                  onTapDown: (details) {
                    Feedback.forTap(context);
                    final RenderBox box =
                        _key.currentContext!.findRenderObject() as RenderBox;
                    final Size size = box.size;
                    final position = details.localPosition;
                    cropAndGemini(
                        position.dx / size.width, position.dy / size.height);
                  },
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

Future<File> cropImageWithRatios({
  required File imageFile,
  required double xRatio,
  required double yRatio,
  required double widthRatio,
  required double heightRatio,
}) async {
  try {
    // Read the image file and convert to Uint8List
    List<int> bytes = await imageFile.readAsBytes();
    Uint8List imageBytes = Uint8List.fromList(bytes);

    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    // Calculate the desired width and height
    int width = (originalImage.width * widthRatio).round();
    int height = (originalImage.height * heightRatio).round();

    // Calculate the center point from the ratios
    int centerX = (originalImage.width * xRatio).round();
    int centerY = (originalImage.height * yRatio).round();

    // Calculate the starting points to center the crop around the tapped point
    int x = centerX - (width ~/ 2);
    int y = centerY - (height ~/ 2);

    // Ensure coordinates stay within image bounds
    x = x.clamp(0, originalImage.width - width);
    y = y.clamp(0, originalImage.height - height);

    // If we hit the bounds, adjust the center point accordingly
    if (x == 0) centerX = width ~/ 2;
    if (x == originalImage.width - width) {
      centerX = originalImage.width - (width ~/ 2);
    }
    if (y == 0) centerY = height ~/ 2;
    if (y == originalImage.height - height) {
      centerY = originalImage.height - (height ~/ 2);
    }

    // Perform the crop
    img.Image croppedImage = img.copyCrop(
      originalImage,
      x: x,
      y: y,
      width: width,
      height: height,
    );

    // Create a temporary file for the cropped image
    String tempPath = imageFile.path.replaceAll('.jpg', '_cropped.jpg');
    File tempFile = File(tempPath);

    // Encode and save the cropped image
    await tempFile.writeAsBytes(img.encodeJpg(croppedImage));

    return tempFile;
  } catch (e) {
    throw Exception('Failed to crop image: $e');
  }
}
