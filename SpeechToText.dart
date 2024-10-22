import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class Speechtotext extends StatefulWidget {
  const Speechtotext({super.key});

  @override
  State<Speechtotext> createState() => _SpeechtotextState();
}

class _SpeechtotextState extends State<Speechtotext> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and say "What is in front of me?"';
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> getSceneDescription() async {
    final response = await http.get(Uri.parse('http://<Raspberry_Pi_IP>:5000/describe_scenery'));
    
    if (response.statusCode == 200) {
      // Parse the response body
      final description = jsonDecode(response.body)['description'];
      
      // Use TTS to speak out the description
      await flutterTts.speak(description);
    } else {
      print('Failed to fetch scene description');
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _text = val.recognizedWords;
            if (_text.toLowerCase().contains("what is in front of me")) {
              // When voice command matches, send a request to Raspberry Pi
              getSceneDescription();
            }
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scene Description App'),
      ),
      body: Center(
        child: Text(
          _text,
          style: const TextStyle(fontSize: 32.0),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Speechtotext(),
  ));
}
