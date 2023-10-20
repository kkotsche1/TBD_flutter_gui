import 'package:flutter/material.dart';

// A widget to display a camera overlay with focus box and instruction
Widget cameraOverlay({
  required Color color,              // Color of the overlay sections
  required Function disposeFunction, // Function to dispose any resources if needed
}) {
  // Aspect ratio for the focus box based on the A4 paper size
  double aspectRatio = 0.707; // A4 paper aspect ratio (8.27 : 11.69)

  return LayoutBuilder(builder: (context, constraints) {
    // Calculate dimensions for the focus box
    double width = constraints.maxWidth * 0.9; // Using 90% of screen width for the focus box
    double height = width / aspectRatio;
    double verticalOffset = constraints.maxHeight * 0.075; // Moving the box 7.5% higher (negative value will move it down)

    return Stack(fit: StackFit.expand, children: [
      // Top overlay covering area above the focus box
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          height: (constraints.maxHeight - height) / 2 - verticalOffset,
          color: color,
        ),
      ),
      // Bottom overlay covering area below the focus box
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: (constraints.maxHeight - height) / 2 + verticalOffset,
          color: color,
        ),
      ),
      // Left overlay covering area to the left of the focus box
      Positioned(
        top: (constraints.maxHeight - height) / 2 - verticalOffset,
        left: 0,
        bottom: (constraints.maxHeight - height) / 2 + verticalOffset,
        child: Container(
          width: (constraints.maxWidth - width) / 2,
          color: color,
        ),
      ),
      // Right overlay covering area to the right of the focus box
      Positioned(
        top: (constraints.maxHeight - height) / 2 - verticalOffset,
        right: 0,
        bottom: (constraints.maxHeight - height) / 2 + verticalOffset,
        child: Container(
          width: (constraints.maxWidth - width) / 2,
          color: color,
        ),
      ),
      // Focus box for the user to align the document with
      Positioned(
        top: (constraints.maxHeight - height) / 2 - verticalOffset,
        left: (constraints.maxWidth - width) / 2,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
        ),
      ),
      // Back button to navigate away from the camera screen
      Positioned(
        top: 10,
        left: 10,
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 42,
          ),
          onPressed: () {
            // Dispose any resources and navigate away from the camera screen
            disposeFunction();
            Navigator.of(context).pop();
          },
        ),
      ),
      // Text instruction for the user on how to align the document
      Positioned(
        top: (constraints.maxHeight - height) / 2 - verticalOffset - 40, // Positioned just above the focus box
        child: Container(
          width: constraints.maxWidth,
          child: Text(
            "Center your document within this box.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    ]);
  });
}
