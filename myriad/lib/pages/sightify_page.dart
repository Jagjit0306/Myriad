import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myriad/components/banner_1.dart';
import 'package:myriad/components/round_button.dart';
import 'package:image_picker/image_picker.dart';

class SightifyPage extends StatefulWidget {
  const SightifyPage({super.key});

  @override
  State<SightifyPage> createState() => _SightifyPageState();
}

class _SightifyPageState extends State<SightifyPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
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
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Text('No image selected'),
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
                onPressed: _takePicture,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}