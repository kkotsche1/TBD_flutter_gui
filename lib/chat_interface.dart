// Importing necessary Dart and Flutter packages
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import "package:flutter/scheduler.dart";
import 'package:flutter/services.dart';
import "package:http/http.dart" as http;

// StatefulWidget that represents the chat interface
class ChatInterface extends StatefulWidget {
  // The original note to be used in the chat
  final String originalNote;

  ChatInterface({required this.originalNote});

  @override
  _ChatInterfaceState createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  // List to hold the chat messages
  List<Message> _messages = [];
  // Controller for the chat input text field
  TextEditingController _textController = TextEditingController();
  // Boolean to indicate if the bot is typing
  bool _isBotTyping = false;
  // Scroll controller for the chat message list
  ScrollController _scrollController = ScrollController();
  bool isWaitingForResponse = false;
  // Focus node for the chat input text field
  FocusNode _messageFocusNode = FocusNode();

  // Function to make a POST request to the chat endpoint and get a response
  Future<String> callChatEndpoint (String noteText, String question) async{
    final url =
    Uri.parse('https://answer-patient-question-2lmpzf7gaa-uc.a.run.app');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'record': noteText, "question":question}),
      );
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then grab the text from the response body.
        String responseString = response.body;
        return responseString;

      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        print('Failed to load response. Status code: ${response.statusCode}');
        return"Something seems to have gone wrong. We will fix it as soon as we can.";
      }
    } catch (e) {
      print('Error occurred: $e');
      return "";
    }
  }

  @override
  void initState() {
    super.initState();

    // Request focus for the message input field after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messageFocusNode.requestFocus();
    });
  }

  // Function to return input decoration for text fields
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white, fontSize: 18),
      filled: true,
      fillColor: Colors.grey[800],
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Color(0xFF5e35b1), width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.0),
      ),
    );
  }

  // Function to build the chat UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            _buildClearMessageButton(),
            SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      buildMessage(context, index, _messages),
                ),
              ),
            ),
            SizedBox(height: 12),
            _buildTextInput(context),
            SizedBox(height: 12)
          ],
        ),
      ),
    );
  }

  // Widget for the "Clear Messages" button
  ElevatedButton _buildClearMessageButton() {
    return ElevatedButton(
      onPressed: () => setState(() {
        _messages.clear();
        isWaitingForResponse = false;
        _messageFocusNode.requestFocus();
      }),
      style: ElevatedButton.styleFrom(
        primary: Color(0xFF2A3C93),  // Setting background color to #2A3C93
      ),
      child: Text('Clear Messages',
          style: TextStyle(fontSize: 14, color: Colors.white)),
    );
  }

  // Widget for the chat input field
  Container _buildTextInput(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildTextInputRow(context),
        ],
      ),
    );
  }

  // Widget for the chat input field
  Column _buildTextInputRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 12),
            _buildInputField(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.grey[800]),
                onPressed: () => _sendMessage(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Row containing the chat input field and send button
  Widget _buildInputField() {
    return Expanded(
      child: TextFormField(
        controller: _textController,
        focusNode: _messageFocusNode,
        style: TextStyle(color: Colors.grey[200]),
        decoration: _inputDecoration('Type your message...')
            .copyWith(
          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), // Adjust these values as needed
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0), // Adjust the value for desired roundness
            borderSide: BorderSide(color: Color(0xFF2A3C93), width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0), // Adjust the value for desired roundness
            borderSide: BorderSide(color: Color(0xFF2A3C93), width: 1.0),
          ),
        ),
        inputFormatters: [LengthLimitingTextInputFormatter(512)],
        onFieldSubmitted: (_) => _sendMessage(),
      ),
    );
  }

  // Function to handle sending a message in the chat
  void _sendMessage() async {
    setState(() {
      isWaitingForResponse = true;
    });

    var currentMessage = _textController.text;
    print(currentMessage);
    if (_textController.text.isNotEmpty) {
      setState(() {
        _messages.add(
          Message(
            text: currentMessage,
            isUser: true,
          ),
        );
      });
      _textController.clear();
      scrollToBottom();

      String response = await callChatEndpoint(widget.originalNote, currentMessage);

      response = response.replaceAll("The patient", "You");

      _displayTypingEffect(response);

    }
    setState(() {
      isWaitingForResponse = false;
    });
  }

  // Function to display a typing effect for the bot's message
  void _displayTypingEffect(String botResponse) async {
    setState(() {
      _isBotTyping = true;
    });
    await Future.delayed(Duration(milliseconds: 50));

    Message botMessage = Message(
      text: '',
      isUser: false,
    );
    setState(() {
      _messages.add(botMessage);
      scrollToBottom();
    });

    for (int i = 0; i < botResponse.length; i++) {
      await Future.delayed(Duration(milliseconds: 3));
      setState(() {
        _messages.removeLast();
        _messages.add(
          Message(
            text: botResponse.substring(0, i + 1),
            isUser: false,
          ),
        );
        scrollToBottom();
      });
    }

    setState(() {
      _isBotTyping = false;
      isWaitingForResponse = false;
    });
    _messageFocusNode.requestFocus();
  }

  // Function to scroll the chat to the bottom
  void scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });
  }
}

// Function to build individual chat messages
Widget buildMessage(BuildContext context, int index, List _messages) {
  dynamic screenSize = MediaQuery.of(context).size;
  final message = _messages[index];
  return Container(
    margin: EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment:
      message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: message.isUser
                ? MediaQuery.of(context).size.width * 0.85
                : MediaQuery.of(context).size.width * 0.85,
          ),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isUser ? Color(0xFF2A3C93) : Colors.grey[700],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: message.isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              SelectableText(
                message.text,
                style: screenSize.width > 1000
                    ? TextStyle(color: Colors.white, fontSize: 16)
                    : TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Model class representing a chat message
class Message {
  final String text;
  final bool isUser;

  Message({
    required this.text,
    required this.isUser,
  });
}