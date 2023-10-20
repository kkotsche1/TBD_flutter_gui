// Importing necessary packages
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'camera_screen.dart';
import 'package:merantix_hackathon_2/loading_page.dart';

// Screen for previewing the captured images
class ImagePreviewScreen extends StatefulWidget {
  // List of images captured and list of available cameras
  final List<File> images;
  final List<CameraDescription>? cameras;

  // Constructor requiring images and cameras as parameters
  ImagePreviewScreen({required this.images, required this.cameras});

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  // The index of the currently displayed image
  int currentIndex = 0;

  // Asynchronous function to add an image using the camera
  Future<void> _addImage() async {
    final newImage = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        // Navigating to the CameraPage to capture an image
        builder: (context) => CameraPage(images: widget.images, cameras: widget.cameras),
      ),
    );
    // If an image was captured, add it to the list
    if (newImage != null) {
      setState(() {
        widget.images.add(newImage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Picture Preview"),
      ),
      body: Column(
        children: [
          SizedBox(height:12),
          // Button to remove the currently displayed image
          ElevatedButton(child: Text("Remove this Image"), onPressed: (){
            setState(() {
              widget.images.removeAt(currentIndex);
              // Adjust the current index if necessary
              if (currentIndex >= widget.images.length && currentIndex > 0) {
                currentIndex--;
              }
              // If no images remain, navigate back
              if(currentIndex == 0){
                Navigator.pop(context);
              }
            });
          }),
          SizedBox(height:24),
          // Display the current image
          Expanded(
            child: Center(
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PageView.builder(
                    itemCount: widget.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.file(
                        widget.images[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Indicator dots for the images
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2.0),
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == index ? Colors.black87 : Colors.black38,
                ),
              );
            }),
          ),
          // Instruction text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Please check the image quality and positioning.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          // Options to add another image or finish
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("Please take images of all pages\n you would like to include in your summary.", textAlign: TextAlign.center,),
                    SizedBox(height:24),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _addImage,
                          child: Text("Add Another Image"),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(width:12),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the LoadingPage after finishing
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoadingPage(widget.images),
                              ),
                            );
                          },
                          child: Text("Finish"),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
