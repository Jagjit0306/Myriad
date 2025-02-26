import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:myriad/helper/tts_functions.dart';

class ColorifyPage extends StatefulWidget {
  final bool talkback;
  const ColorifyPage({
    super.key,
    this.talkback = false,
  });

  @override
  State<ColorifyPage> createState() => _ColorDetectionPageState();
}

class _ColorDetectionPageState extends State<ColorifyPage> {
  CameraController? _controller;
  TTS tts = TTS();
  List<CameraDescription>? cameras;
  Color selectedColor = Colors.white;

  @override
  void initState() {
    super.initState();
    if (widget.talkback) {
      tts.initTTS();
    }
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras![0],
      ResolutionPreset.high,
    );
    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _controller!.takePicture();
      await _analyzeColor(photo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: $e')),
        );
      }
    }
  }

  Future<void> _analyzeColor(XFile photo) async {
    try {
      // Load the image file
      File imageFile = File(photo.path);
      Uint8List bytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        // Get the center pixel
        int centerX = originalImage.width ~/ 2;
        int centerY = originalImage.height ~/ 2;

        // Get RGB values directly
        img.Pixel pixel = originalImage.getPixel(centerX, centerY);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Update the selected color
        if (mounted) {
          setState(() {
            selectedColor = Color.fromARGB(255, r, g, b);
          });

          // Show the detected color
          if (widget.talkback) {
            tts.speak(_getColorName(selectedColor));
          } else {
            _showColorDialog(_getColorName(selectedColor));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing color: $e')),
        );
      }
    }
  }

  void _showColorDialog(String colorName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detected Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('The color at the center is: $colorName'),
            const SizedBox(height: 10),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: selectedColor,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getColorName(Color color) {
    // return ColorNames.guess(color);
    return getNearestColorName(color);
  }

  static const Map<String, Color> basicColors = {
    "Light Red": Color(0xFFFFA07A),
    "Red": Colors.red,
    "Dark Red": Color(0xFF8B0000),
    "Light Green": Color(0xFF90EE90),
    "Green": Colors.green,
    "Dark Green": Color(0xFF006400),
    "Light Blue": Color(0xFFADD8E6),
    "Blue": Colors.blue,
    "Dark Blue": Color(0xFF00008B),
    "Light Yellow": Color(0xFFFFFFE0),
    "Yellow": Colors.yellow,
    "Dark Yellow": Color(0xFF9B870C),
    "Light Orange": Color(0xFFFFDAB9),
    "Orange": Colors.orange,
    "Dark Orange": Color(0xFFFF8C00),
    "Light Purple": Color(0xFFD8BFD8),
    "Purple": Colors.purple,
    "Dark Purple": Color(0xFF4B0082),
    "Light Brown": Color(0xFFF5DEB3),
    "Brown": Colors.brown,
    "Dark Brown": Color(0xFF654321),
    "Light Grey": Color(0xFFD3D3D3),
    "Grey": Colors.grey,
    "Dark Grey": Color(0xFF505050),
    "Black": Colors.black,
    "White": Colors.white,
  };

  /// Function to get the nearest basic color name
  String getNearestColorName(Color color) {
    String closestColor = "Unknown";
    double minDistance = double.infinity;

    for (var entry in basicColors.entries) {
      double distance = _colorDistance(color, entry.value);
      if (distance < minDistance) {
        minDistance = distance;
        closestColor = entry.key;
      }
    }

    return closestColor;
  }

  /// Function to calculate color distance
  double _colorDistance(Color c1, Color c2) {
    return (c1.r - c2.r) * (c1.r - c2.r) +
        (c1.g - c2.g) * (c1.g - c2.g) +
        (c1.b - c2.b) * (c1.b - c2.b) * 1.0; // Ensure it returns double
  }

  @override
  void dispose() {
    _controller?.dispose();
    if(widget.talkback) {
      tts.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Colorify'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_controller == null || !_controller!.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get the camera preview aspect ratio
          double aspectRatio = _controller!.value.previewSize!.height /
              _controller!.value.previewSize!.width;

          Widget cameraPreview = CameraPreview(_controller!);

          // Apply fix only for Android
          if (Platform.isAndroid) {
            cameraPreview = Transform.rotate(
              angle: 90 * 3.1415926535 / 180, // Rotate preview 90 degrees
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxWidth * aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
            );
          }
          return Stack(
            children: [
              cameraPreview,
              // const Text('hi'),
              GestureDetector(
                onTap: _takePicture,
                child: Center(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: CrosshairPainter(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw horizontal line
    canvas.drawLine(
      Offset(size.width / 2 - 20, size.height / 2),
      Offset(size.width / 2 + 20, size.height / 2),
      paint,
    );

    // Draw vertical line
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2 - 20),
      Offset(size.width / 2, size.height / 2 + 20),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
