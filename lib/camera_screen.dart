// Importing necessary packages
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import "dart:io";
import "dart:ui";
import 'camera_overlay.dart';
import 'image_preview_screen.dart';

// Screen for capturing images using the camera
class CameraPage extends StatefulWidget {
  // List of available cameras and images captured
  final List<CameraDescription>? cameras;
  List<File> images;

  // Constructor requiring cameras and images as parameters
  CameraPage({required this.cameras, required this.images});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  bool _isRearCameraSelected = true; // Flag to check if rear camera is selected
  late double screenWidth; // Screen width, might be used for responsive layouts

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Initialize camera when the widget is created
  }

  @override
  void dispose() {
    _cameraController?.dispose(); // Dispose the camera controller when not needed
    super.dispose();
  }

  // Initialize the camera
  void _initializeCamera() async {
    // Dispose of the old controller if it exists
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;  // Set to null after disposing
    }

    // Initialize the new controller based on the selected camera
    _cameraController = CameraController(
      _isRearCameraSelected ? widget.cameras![0] : widget.cameras![1],
      ResolutionPreset.high,
    );

    // Wait for the controller to be fully initialized
    await _cameraController!.initialize();

    // Set the flash mode to off after initialization
    if (_cameraController!.value.isInitialized && _cameraController!.value.flashMode != FlashMode.off) {
      await _cameraController!.setFlashMode(FlashMode.off);
    }

    // Check if the widget is still in the widget tree
    if (!mounted) return;

    // Rebuild the UI
    setState(() {});
  }

  // Function to capture an image
  Future<void> takePicture() async {
    if (!_cameraController!.value.isInitialized || _cameraController!.value.isTakingPicture) {
      return null;
    }

    XFile picture = await _cameraController!.takePicture();
    File croppedFile = File(picture.path);

    widget.images.add(croppedFile);

    // Navigate to Image Preview Screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImagePreviewScreen(images: widget.images, cameras: widget.cameras,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          // Show the camera preview if the camera is initialized, otherwise show a loading indicator
          (_cameraController!.value.isInitialized)
              ? CameraPreview(_cameraController!)
              : Center(child: CircularProgressIndicator()),
          // Overlay for the camera screen
          cameraOverlay(
            color: Color(0x55000000),
            disposeFunction: dispose,
          ),
          // Bottom navigation bar with camera options
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.17,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                color: Color(0xFF212121),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Switch camera button
                  Expanded(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 30,
                      icon: Icon(
                        _isRearCameraSelected
                            ? CupertinoIcons.switch_camera
                            : CupertinoIcons.switch_camera_solid,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() => _isRearCameraSelected = !_isRearCameraSelected);
                        _initializeCamera();
                      },
                    ),
                  ),
                  // Capture button with multiple layers for design
                  Expanded(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            onPressed: takePicture,
                            iconSize: 70,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.circle, color: Colors.white),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            onPressed: takePicture,
                            iconSize: 65,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.circle, color: Color(0xFF212121)),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            onPressed: takePicture,
                            iconSize: 50,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.circle, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
