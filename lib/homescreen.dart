import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 2,
              child: ElevatedButton(
                onPressed: () {
                  // Action for top-left button
                  print('Button Pressed: Triggering haptic feedback');
                  HapticFeedback.vibrate();
                },
                child: Text('Location'),
                style: ElevatedButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 2,
              child: ElevatedButton(
                onPressed: () {
                  // Action for top-right button
                  print('Button Pressed: Triggering haptic feedback');
                  HapticFeedback.vibrate();
                },
                child: Text('Settings'),
                style: ElevatedButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 2,
              child: ElevatedButton(
                onPressed: () {
                  // Action for bottom-left button
                  print('Button Pressed: Triggering haptic feedback');
                  HapticFeedback.vibrate();
                },
                child: Text(' Camera'),
                style: ElevatedButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 2,
              child: ElevatedButton(
                onPressed: () {
                  // Action for bottom-right button
                  print('Button Pressed: Triggering haptic feedback');
                  HapticFeedback.vibrate();
                },
                child: Text('Emergency'),
                style: ElevatedButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  backgroundColor: Colors.orange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
