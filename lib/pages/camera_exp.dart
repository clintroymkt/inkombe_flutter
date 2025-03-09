import 'package:adv_camera/adv_camera.dart';
import 'package:flutter/material.dart';


  String id = DateTime.now().toIso8601String();



class CameraExp extends StatefulWidget {
  final String id;

  const CameraExp({Key? key, required this.id}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(child: Text('Press Floating Button to access camera')),
      floatingActionButton: FloatingActionButton(
        heroTag: "test3",
        child: Icon(Icons.camera),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                String id = DateTime.now().toIso8601String();
                return CameraApp(id: id);
              },
            ),
          );
        },
      ),
    );
  }
}

class CameraApp extends StatefulWidget {
  final String id;

  const CameraApp({Key? key, required this.id}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  List<String> pictureSizes = <String>[];
  String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdvCamera Example'),
      ),
      body: SafeArea(
        child: AdvCamera(
          initialCameraType: CameraType.rear,
          onCameraCreated: _onCameraCreated,
          onImageCaptured: (String path) {
            if (this.mounted)
              setState(() {
                imagePath = path;
              });
          },
          cameraPreviewRatio: CameraPreviewRatio.r16_9,
          focusRectColor: Colors.purple,
          focusRectSize: 200,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "capture",
        child: Icon(Icons.camera),
        onPressed: () {
          cameraController!.captureImage();
        },
      ),
    );
  }

  AdvCameraController? cameraController;

  _onCameraCreated(AdvCameraController controller) {
    this.cameraController = controller;

    this.cameraController!.getPictureSizes().then((pictureSizes) {
      setState(() {
        this.pictureSizes = pictureSizes ?? <String>[];
      });
    });
  }
}