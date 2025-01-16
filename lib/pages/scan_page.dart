import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imgLib;
import '../utils/landmark_extractor.dart';
import '../main.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? cameraController;
  CameraImage? imgCamera;
  bool isProcessing = false;
  String result = '';
  late LandMarkModelRunner landMarkModelRunner;

  @override
  void initState() {
    super.initState();
    landMarkModelRunner = LandMarkModelRunner();
    initCamera();
  }

  void initCamera() async {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    await cameraController!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> captureAndProcessImage() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      print("Camera is not initialized.");
      return;
    }

    if (isProcessing) {
      print("Image processing is already in progress.");
      return; // Prevent multiple simultaneous invocations
    }

    try {
      setState(() {
        isProcessing = true;
        result = "Processing image...";
      });

      // Step 1: Capture an image
      print("Capturing image...");
      XFile? imageFile;
      try {
        imageFile = await cameraController!.takePicture();
        print("Image captured at path: ${imageFile.path}");
      } catch (e) {
        throw Exception("Failed to capture image: $e");
      }

      if (imageFile == null) {
        throw Exception("Image file is null. Camera might not have captured the image.");
      }

      // Step 2: Read the image bytes
      final bytes = await imageFile.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception("Image bytes are empty. The file might be corrupted.");
      }
      print("Image bytes length: ${bytes.length}");

      // Step 3: Decode the image
      final imgLib.Image? decodedImage = imgLib.decodeImage(bytes);
      if (decodedImage == null) {
        throw Exception("Error decoding image. Check if the image format is supported.");
      }
      print("Decoded image size: ${decodedImage.width}x${decodedImage.height}");

      // Step 4: Resize the image
      final imgLib.Image resizedImage = imgLib.copyResize(decodedImage, width: 120, height: 120);
      print("Resized image size: ${resizedImage.width}x${resizedImage.height}");

      // Step 5: Convert to PNG format
      final pngBytes = Uint8List.fromList(imgLib.encodePng(resizedImage));
      if (pngBytes.isEmpty) {
        throw Exception("Failed to convert resized image to PNG bytes.");
      }
      print("PNG bytes length: ${pngBytes.length}");

      // Step 6: Run the model
      try {
        print("Running the model...");
        final output = await landMarkModelRunner.run(pngBytes);

        if (output.isEmpty || output.any((row) => row.isEmpty)) {
          throw Exception("Model returned empty or invalid output.");
        }

        print("Model output received: ${output.length} rows of ${output[0].length} columns.");

        // Format output to display multiple rows
        String outputString = output
            .map((row) => row.map((value) => value.toStringAsFixed(2)).join(", "))
            .join("; ");

        setState(() {
          result = "Model Output:\n$outputString";
        });
      } catch (e, stackTrace) {
        throw Exception("Model execution failed: $e \n $stackTrace");
      }

    } catch (e, stackTrace) {
      print("Error processing image: $e");
      print(stackTrace);
      setState(() {
        result = "Error processing image.";
      });
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }




  @override
  void dispose() {
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
                    child: Container(
                      margin: const EdgeInsets.only(top: 35.0),
                      height: 270.0,
                      width: 360.0,
                      child: cameraController == null ||
                          !cameraController!.value.isInitialized
                          ? const SizedBox(
                        height: 270.0,
                        width: 360.0,
                        child: Icon(
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
                ],
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await captureAndProcessImage();
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text("Capture & Process"),
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: SingleChildScrollView(
                    child: Text(
                      result,
                      style: const TextStyle(
                        backgroundColor: Colors.white54,
                        fontSize: 20.0,
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
