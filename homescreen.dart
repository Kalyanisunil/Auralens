import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Listening...';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _startListening();  // Start listening when the app initializes
  }

  // Function to trigger TTS
  void _speak(String text) async {
    await flutterTts.speak(text);
  }

  // Function to start listening continuously
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        print('onStatus: $val');
        if (val == 'done' || val == 'notListening') {
          _startListening();  // Restart listening when it stops
        }
      },
      onError: (val) {
        print('onError: $val');
        _startListening();  // Restart listening on error
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (val) {
        setState(() {
          _text = val.recognizedWords;
          _handleVoiceCommand(_text);  // Process recognized voice command
        });
      });
    }
  }

  // Handle recognized voice commands
  void _handleVoiceCommand(String command) {
    command = command.toLowerCase();

    if (command.contains("capture image")) {
      Navigator.pushNamed(context, '/camera');  // Navigate to the camera screen
    } else if (command.contains("describe scene")) {
      _captureAndDescribeScene();  // Call the Raspberry Pi to describe the scene
    } else if (command.contains("open settings")) {
      Navigator.pushNamed(context, '/settings');  // Navigate to the settings screen
    } else if (command.contains("view saved images")) {
      Navigator.pushNamed(context, '/gallery');  // Navigate to the gallery screen
    } else if (command.contains("help")) {
      _speak("You can say commands like Capture Image, Describe Scene, Open Settings, or View Saved Images.");
    } else if (command.contains("stop listening")) {
      _speech.stop();  // Stop listening
      setState(() => _isListening = false);
      _speak("Voice recognition stopped.");
    } else if (command.contains("start listening")) {
      _startListening();  // Restart listening
      _speak("Voice recognition started.");
    } else if (command.contains("exit")) {
      _speak("Exiting the app.");
      Navigator.pop(context);  // Close the current screen or exit the app
    } else {
      _speak("Command not recognized. Please try again.");
    }
  }

  // Function to send a request to Raspberry Pi to capture and describe the scene
  Future<void> _captureAndDescribeScene() async {
    _speak("Capturing the scene...");
    
    try {
      // Replace <Raspberry_Pi_IP> with the actual IP address of the Raspberry Pi
      final response = await http.get(Uri.parse('http://<Raspberry_Pi_IP>:5000/describe_scenery'));

      if (response.statusCode == 200) {
        final description = jsonDecode(response.body)['description'];
        await flutterTts.speak(description);  // Speak out the description
      } else {
        _speak('Failed to fetch scene description.');
      }
    } catch (e) {
      _speak('Error connecting to Raspberry Pi.');
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Display recognized voice input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Voice Input: $_text',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildGridButton("Capture Image", Icons.camera, context),
                _buildGridButton("Saved Images", Icons.image, context),
                _buildGridButton("Settings", Icons.settings, context),
                _buildGridButton("Help", Icons.help, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridButton(String title, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _speak(title);  // Speak button label
        if (title == "Capture Image") {
          Navigator.pushNamed(context, '/camera');
        }
        // Add more navigation for other buttons if needed
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        color: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
