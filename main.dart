// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_tts/flutter_tts.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Scenery Describer',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String description = "";
//   final FlutterTts flutterTts = FlutterTts();

//   @override
//   void initState() {
//     super.initState();
//     _initializeTts();
//   }

//   /// Initializes the Text-to-Speech engine.
//   Future<void> _initializeTts() async {
//     try {
//       var engines = await flutterTts.getEngines;
//       if (engines.isNotEmpty) {
//         print("Available TTS engines: $engines");
//       } else {
//         print("No TTS engines available");
//       }
//     } catch (e) {
//       print("TTS Initialization Error: $e");
//     }
//   }

//   /// Calls the API to analyze the scene and retrieves a description.
//   Future<void> analyzeScene() async {
//     try {
//       final response = await http.get(Uri.parse('http://192.168.152.175:5000/analyze'));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           description = data['description'];
//         });
//         await _speakDescription(description);
//       } else {
//         throw Exception('Failed to analyze scene: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print("Error analyzing scene: $e");
//     }
//   }

//   /// Speaks the provided text using Text-to-Speech.
//   Future<void> _speakDescription(String text) async {
//     try {
//       await flutterTts.setLanguage("en-US");
//       await flutterTts.setPitch(1.0);
//       await flutterTts.speak(text);
//     } catch (e) {
//       print("Error speaking description: $e");
//     }
//   }

//   @override
//   void dispose() {
//     flutterTts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Scenery Describer'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: analyzeScene,
//               child: Text('Describe Scenery'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               description.isNotEmpty ? description : "No description available",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AURA LENS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String description = "";
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  /// Initializes the Text-to-Speech engine.
  Future<void> _initializeTts() async {
    try {
      var engines = await flutterTts.getEngines;
      if (engines.isNotEmpty) {
        print("Available TTS engines: $engines");
      } else {
        print("No TTS engines available");
      }
    } catch (e) {
      print("TTS Initialization Error: $e");
    }
  }

  /// Calls the API to analyze the scene and retrieves a description.
  Future<void> analyzeScene() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.152.175:5000/analyze'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          description = data['description'];
        });
        await _speakDescription(description);
      } else {
        throw Exception('Failed to analyze scene: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error analyzing scene: $e");
    }
  }

  /// Speaks the provided text using Text-to-Speech.
  Future<void> _speakDescription(String text) async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(text);
    } catch (e) {
      print("Error speaking description: $e");
    }
  }

  /// Dummy functionality for additional buttons (can be implemented as needed).
  Future<void> recognizeCurrency() async {
    await _speakButtonLabel("Currency Recognition");
    print("Currency Recognition Button Pressed");
  }

  // Future<void> triggerPanic() async {
  //   await _speakButtonLabel("Panic Button");
  //   print("Panic Button Pressed");
  // }
 Future<void> panicButton() async {
  await _speakButtonLabel("Panic Button Pressed");
  print("Panic Button Pressed");

  // Request location permission if not already granted
  if (await Permission.location.isDenied) {
    await Permission.location.request();
  }

  try {
    // Get the current location
    Position position = await Geolocator.getCurrentPosition( desiredAccuracy: LocationAccuracy.high);

    // Format the location URL for Google Maps
    String locationUrl = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

    // Message to be sent to caretaker
    String message = "Emergency! The user needs help. Here is the location: $locationUrl";

    // Caretaker's phone number
    String caretakerPhoneNumber = "919188271040"; // Replace with actual phone number

    // Send the SMS using Telephony
    final Telephony telephony = Telephony.instance;

    telephony.sendSms(
      to: caretakerPhoneNumber,
      message: message,
    );

    print("Alert message sent with location.");
  } catch (e) {
    print("Failed to get location or send SMS: $e");
  }
}

  Future<void> emergencyContact() async {
    await _speakButtonLabel("Emergency Contact");
    print("Emergency Contact Button Pressed");
  }
   Future<void> weather() async {
    await _speakButtonLabel("Emergency Contact");
    print("Emergency Contact Button Pressed");
  }
   Future<void> Call911() async {
    await _speakButtonLabel("Emergency Contact");
    print("Emergency Contact Button Pressed");
  }
  
 Future<void> Location() async {
  await _speakButtonLabel("Emergency Contact");
  print("Emergency Contact Button Pressed");

  const googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=emergency+services";

  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  } else {
    throw 'Could not open Google Maps.';
  }
}

  /// Speaks the button label when pressed
  Future<void> _speakButtonLabel(String label) async {
    try {
      await flutterTts.speak(label);
    } catch (e) {
      print("Error speaking button label: $e");
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aura Lens - Vision Assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Creates a 2x2 grid
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 251, 255, 27), // Panic button in red color
                    ),
                    onPressed: () async {
                      await _speakButtonLabel("Scenery");
                      await analyzeScene();
                    },
                    child: Text('Scenery'),
                  ),
                  ElevatedButton(
                    onPressed: recognizeCurrency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 148, 170, 236), // Panic button in red color
                    ), // Reads and handles button press
                    child: Text('Currency '),
                  ),
                  ElevatedButton(
                    onPressed: panicButton, // Reads and handles button press
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Panic button in red color
                    ),
                    child: Text('Panic Button'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 179, 110, 196), // Panic button in red color
                    ),
                    onPressed:
                        emergencyContact, // Reads and handles button press
                    child: Text('Emergency '),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 159, 159, 189), // Panic button in red color
                    ),
                    onPressed: Call911, //
                    child: Text('Call 911'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 122, 194, 105), // Panic button in red color
                    ),
                    onPressed:
                        Location, // Reads and handles button press
                    child: Text('Location'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              description.isNotEmpty ? description : "No description available",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
