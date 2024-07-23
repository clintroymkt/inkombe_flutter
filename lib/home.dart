import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:inkombe_flutter/main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isWorking = false;
  String result = '';
  CameraController? cameraController;
  CameraImage? imgCamera;

  void initCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        cameraController!.startImageStream((imageFromStream) {
          if (!isWorking) {
            isWorking = true;
            imgCamera = imageFromStream;
            runModelOnStream();
          }
        });
      });
    });
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> runModelOnStream() async {
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: imgCamera!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera!.height,
        imageWidth: imgCamera!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );
      result = '';

      recognitions!.forEach((response) {
        result += response["label"] + "  " + (response["confidence"] as double).toStringAsFixed(2) + "\n\n";
      });

      setState(() {
        result;
      });
      isWorking = false;
    }
  }

  @override
  void dispose() {
    Tflite.close();
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Cow Breed Recognizer Module")),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/backscreen.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                      height: 320.0,
                      width: 360.0,
                      child: Image.asset("assets/frame.jpg"),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        initCamera();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 35.0),
                        height: 270.0,
                        width: 360.0,
                        child: imgCamera == null
                            ? Container(
                          height: 270.0,
                          width: 360.0,
                          child: const Icon(
                            Icons.photo_camera_front,
                            color: Colors.amberAccent,
                            size: 40.0,
                          ),
                        )
                            : AspectRatio(
                          aspectRatio: cameraController!.value.aspectRatio,
                          child: CameraPreview(cameraController!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 55.0),
                  child: SingleChildScrollView(
                    child: Text(
                      result,
                      style: const TextStyle(
                        backgroundColor: Colors.white54,
                        fontSize: 25.0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
