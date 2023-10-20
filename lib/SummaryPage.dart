// Importing necessary Dart and Flutter packages
import "dart:convert";
import "package:flutter/material.dart";
import 'chat_interface.dart';
import "package:http/http.dart" as http;

// StatefulWidget that represents the summary page
class SummaryPage extends StatefulWidget {
  // Variables to hold the summary and the original text
  final String summary;
  final String originalText;

  // Constructor to initialize the summary and original text
  SummaryPage({required this.summary, required this.originalText});

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  // List of available languages for translation
  final List<String> languages = ['English', 'Spanish', 'French', 'German', "Ukranian"];
  // Variable to hold the currently selected language
  String selectedLanguage = 'English';
  // Variable to hold the displayed summary (after translation)
  String? displayedSummary;
  // Variable to hold the language code for API request
  String languageCode = "en";
  // Variable to hold the original summary before translation
  late String ogSummary;

  @override
  void initState() {
    super.initState();
    // Initialize the displayed summary and the original summary
    ogSummary = widget.summary;
    displayedSummary = widget.summary;
  }

  // Function to translate the summary based on selected language
  Future<String> translateSummary() async {

    // Mapping the selected language to the corresponding language code
    if (selectedLanguage == "English"){
      languageCode = "EN-US";
    }
    if (selectedLanguage == "Arabic"){
      languageCode = "ar";
    }
    if (selectedLanguage == "Ukranian"){
      languageCode = "UK";
    }
    if (selectedLanguage == "Spanish"){
      languageCode = "ES";
    }
    if (selectedLanguage == "French"){
      languageCode = "FR";
    }
    if (selectedLanguage == "German"){
      languageCode = "DE";
    }

    //TODO Implement new translation API call reflecting the google cloud translation API endpoint

    // final String baseUrl = "https://publicly-relative-lemming.ngrok-free.app";
    // final Uri url = Uri.parse("$baseUrl/translate");
    //
    // final response = await http.post(
    //   url,
    //   headers: {
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode({
    //     'submitted_query': displayedSummary!,
    //     'dest_language': languageCode,
    //   }),
    // );

    return "Implement API call functionality.";

    if (response.statusCode == 200) {
      setState(() {
        displayedSummary = jsonDecode(response.body)['response'];
      });
      return jsonDecode(response.body)['response'];
    }else{
      return displayedSummary!;
    }
  }

  // Function to build the UI of the summary page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: <Widget>[
              SizedBox(height:12),
              Text("Select your Language", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              SizedBox(height:8),
              // Language Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(0xFF2A3C93), // Change to light blue background
                  borderRadius: BorderRadius.circular(30),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedLanguage,
                    dropdownColor: Color(0xFF2A3C93), // Ensure the dropdown items also have a light blue background
                    items: languages.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(color: Colors.white)), // White text color
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLanguage = newValue!;
                      });
                      translateSummary();
                    },
                  ),
                ),
              ),

              // 90% of the screen for the summary
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text("Your Summary", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                        SizedBox(height:12),
                        Text(displayedSummary!),
                      ],
                    ),
                  ),
                ),
              ),

              // 10% of the screen for the button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: ChatInterface(originalNote: widget.originalText,),
                        );
                      },
                    );
                  },
                  child: Text('Ask Question'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
