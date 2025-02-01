import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  late CameraDescription _camera;
  bool _isCameraInitialized = false;
  bool _isFrontCamera = false;
  String _imagePath = ''; // Initialize as an empty string

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _camera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);

    _controller = CameraController(
      _camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller.initialize();

    // Set the camera to preview in the correct orientation
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _toggleCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _camera = _isFrontCamera
          ? _cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front)
          : _cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back);
    });

    await _controller.dispose();
    _controller = CameraController(_camera, ResolutionPreset.high);
    await _controller.initialize();

    setState(() {});
  }

  Future<void> _takePicture() async {
    try {
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';

      await _controller.takePicture().then((XFile file) async {
        // Load the image using the image package to fix the orientation
        final bytes = await file.readAsBytes();
        img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

        if (image != null) {
          // Rotate the image if needed
          img.Image fixedImage = img.copyRotate(image,
              90); // Rotate by 90 degrees or -90 depending on your device

          // Save the rotated image back to the file
          final newPath =
              '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_fixed.png';
          final newFile = File(newPath)
            ..writeAsBytesSync(img.encodePng(fixedImage));

          setState(() {
            _imagePath = newFile.path; // Set the new image path
          });
        }
      });
    } catch (e) {
      print("Error capturing picture: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Page')),
      body: _isCameraInitialized
          ? Stack(
              children: [
                // CameraPreview with a 90-degree rotation applied
                Transform.rotate(
                  angle: 90 * 3.1415927 / 180, // Convert 90 degrees to radians
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.switch_camera, color: Colors.white),
                    onPressed: _toggleCamera,
                  ),
                ),
                Positioned(
                  bottom: 80,
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  child: IconButton(
                    icon: Icon(Icons.camera, color: Colors.white, size: 60),
                    onPressed: _takePicture,
                  ),
                ),
                if (_imagePath.isNotEmpty)
                  Positioned(
                    bottom: 20,
                    left: MediaQuery.of(context).size.width / 2 - 30,
                    child: GestureDetector(
                      child: CircleAvatar(
                        backgroundImage: FileImage(File(_imagePath)),
                        radius: 30,
                      ),
                    ),
                  ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
