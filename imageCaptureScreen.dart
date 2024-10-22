import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Database
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _cameraController.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Camera initialization failed: $e');
      _showError('Failed to initialize camera');
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final directory = await getApplicationDocumentsDirectory();
      final path = join(
        directory.path,
        '${DateTime.now()}.png',
      );

      final image = await _cameraController.takePicture();
      File imageFile = File(image.path);

      Navigator.push(
        context as BuildContext,
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      print('Error taking picture: $e');
      _showError('Failed to take picture');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera '),
      ),
      body: _isCameraInitialized
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_cameraController);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
          : Center(child: CircularProgressIndicator()), 
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  DisplayPictureScreen({required this.imagePath});

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance; // Initialize Firebase Database
  bool _isUploading = false;

  Future<void> _uploadImage() async {
    try {
      setState(() {
        _isUploading = true; // Show uploading indicator
      });

      // Upload image to Firebase Storage
      final ref = _storage.ref('images/${Uuid().v1()}.jpg');
      final uploadTask = await ref.putFile(File(widget.imagePath));

      // Get the image URL
      final imageUrl = await ref.getDownloadURL();

      // Save image metadata to Firebase Realtime Database
      final imageData = {
        "url": imageUrl,
        "timestamp": DateTime.now().toIso8601String(),
        "filename": basename(widget.imagePath),
      };

      // Push image data to the database
      await _database.ref().child("images").push().set(imageData);

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      print('Image upload failed: $e');
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Picture'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(File(widget.imagePath)),
          ),
          _isUploading
              ? CircularProgressIndicator()
              : SizedBox(height: 0), 
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadImage,
        child: Icon(Icons.cloud_upload),
      ),
    );
  }
}
