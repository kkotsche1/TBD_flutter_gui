// Importing necessary Dart and Flutter packages
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import "package:http/http.dart" as http;
import 'SummaryPage.dart';
import "dart:io";

// A StatefulWidget that represents a loading page
class LoadingPage extends StatefulWidget {
  // List of image files to be processed
  final List<File> images;
  LoadingPage(this.images);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  // A string to hold the complete medical note after processing
  String completeMedicalNote = "";

  @override
  void initState() {
    super.initState();
    // Initialize asynchronous operations when the state is initialized
    initAsync();
  }

  // Function to upload files to Firebase and return their download URLs
  Future<List<String>> uploadFilesAndReturnURLs(List<File> files) async {
    List<String> downloadURLs = [];

    for (File file in files) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask task = FirebaseStorage.instance.ref('uploads/$fileName').putFile(file);
      TaskSnapshot snapshot = await task.whenComplete(() => {});
      String downloadURL = await snapshot.ref.getDownloadURL();
      downloadURLs.add(downloadURL);
    }

    return downloadURLs;
  }

  // Initialize the asynchronous process of uploading files, getting OCR results, and navigating to summary page
  void initAsync() async {
    List<String> urlList = await uploadFilesAndReturnURLs(widget.images);
    completeMedicalNote = await getImageOCRString(urlList);
    String summary = await fetchModelSummary(completeMedicalNote);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SummaryPage(summary: summary, originalText: completeMedicalNote,)),
    );
  }

  // Fetch the OCR result for a given image URL
  Future<String> fetchStringOCR(String url) async {
    final response = await http.get(Uri.parse('https://ocr-v2-2lmpzf7gaa-uc.a.run.app?image_url=$url'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return ""; // Return an empty string in case of a non-successful response
    }
  }

  // Get the OCR results for a list of image URLs and concatenate them
  Future<String> getImageOCRString(List<String> urls) async {
    List<String> ocrResults = await Future.wait(urls.map(fetchStringOCR));
    return ocrResults.join();
  }

  // Fetch a summarized version of the complete medical note using an external API
  Future<String> fetchModelSummary(String prompt) async {
    final apiUrl = "https://comprehensible-summary-2lmpzf7gaa-uc.a.run.app";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'record': prompt}),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print("Failed to load response from the model. Status code: ${response.statusCode}");
        return "Something went wrong, please try again :)";
      }
    } catch (e) {
      print("Error fetching model’s response: $e");
      return "Something went wrong, please try again :)";
    }
  }

  // Define the widget structure for the loading page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
            SizedBox(height: 20),
            Text('We are processing your Documents'),
          ],
        ),
      ),
    );
  }
}
