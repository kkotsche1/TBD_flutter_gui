// Importing necessary packages
import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import 'camera_screen.dart';

// Screen for checking and requesting necessary permissions
class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Flags to track permission status
  bool _cameraPermissionGranted = false;
  bool _micPermissionGranted = false;

  // List to store available cameras on the device
  late List<CameraDescription> _cameras;

  // Function to check and request camera & microphone permissions
  _checkAndRequestPermissions() async {
    // Check camera permission
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
    }

    // Check microphone permission
    var microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      microphoneStatus = await Permission.microphone.request();
    }

    // Update the permission status in the state
    setState(() {
      _cameraPermissionGranted = cameraStatus.isGranted;
      _micPermissionGranted = microphoneStatus.isGranted;
    });

    // If permissions are granted, initialize cameras and navigate to the CameraPage
    if (_cameraPermissionGranted && _micPermissionGranted) {
      await _initializeCameras();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraPage(cameras: _cameras, images: [])),
      );
    }
  }

  // Function to initialize the available cameras on the device
  _initializeCameras() async {
    _cameras = await availableCameras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2A3C92),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Placeholder for the application's logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset("assets/TBD Round.png", fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 30),

              // Application title and subtitle
              Text(
                'Welcome to TBD',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                'Empowering your health literacy\none snap at a time',
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Button to start the permission check and request flow
              ElevatedButton(
                onPressed: _checkAndRequestPermissions,
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Color(0xFF2A3C92),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Get Started'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
