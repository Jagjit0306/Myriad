import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:colornames/colornames.dart';

class ColorifyPage extends StatefulWidget {
  const ColorifyPage({super.key});

  @override
  State<ColorifyPage> createState() => _ColorDetectionPageState();
}

class _ColorDetectionPageState extends State<ColorifyPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  Color selectedColor = Colors.white;

  @override
  void initState() {
    super.initState();
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
          _showColorDialog(_getColorName(selectedColor));
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
            // const SizedBox(height: 10),
            // Text(
            //   'RGB: (${selectedColor.r}, ${selectedColor.g}, ${selectedColor.b})',
            //   style: const TextStyle(fontSize: 12),
            // ),
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
    return ColorNames.guess(color);
  }

  @override
  void dispose() {
    _controller?.dispose();
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
