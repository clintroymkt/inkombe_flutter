import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:inkombe_flutter/widgets.dart';
import '../utils/cosine_similarity_check.dart';
import '../utils/landmark_extractor.dart';
import '../main.dart';
import 'cow_profile_page.dart';
import 'create_cow_page_copy.dart';
import '../utils/image_processor.dart';

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
  late List<dynamic> arrayResult;
  List<double> faceEmbeddings = [];
  List<double> noseEmbeddings = [];
  late File? pngFile;
  late LandMarkModelRunner landMarkModelRunner;
  late ImageProcessor imageProcessor;
  CosineSimilarityCheck similarityChecker = CosineSimilarityCheck();



  @override
  void initState() {
    super.initState();
    landMarkModelRunner = LandMarkModelRunner();
    initCamera();
    imageProcessor = ImageProcessor(landMarkModelRunner: landMarkModelRunner);
  }

  // collect garbage
  @override
  void dispose(){
    super.dispose();
    cameraController?.dispose();
    imgCamera;
    isProcessing;
    result;
    faceEmbeddings;
    noseEmbeddings;
    landMarkModelRunner.dispose();
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

      // Step 6: Run the model
      try {
        print("Running the model...");
        final output = await imageProcessor.processImage(imageFile);

        // position 0 is bounding box output
        // position 1 is face regression output
        // position 2 is classification output
        // position 3 is face regression output
        setState(() {
          faceEmbeddings = output["faceEmbeddings"]!;
          noseEmbeddings = output["noseEmbeddings"]!;
          pngFile = output["file"]; // Update the PNG file
          result = "Image processed successfully!";
        });


        pngFile = pngFile;

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera feed with aspect ratio maintained
          cameraController == null || !cameraController!.value.isInitialized
              ? Container(
            color: Colors.black, // Fallback color while the camera initializes
            child: const Center(
              child: Icon(
                Icons.photo_camera_front,
                color: Colors.amberAccent,
                size: 40.0,
              ),
            ),
          )
              : Center(
            child: FittedBox(
              fit: BoxFit.cover, // Ensures the camera feed fills the screen
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height /
                    cameraController!.value.aspectRatio,
                child: AspectRatio(
                  aspectRatio: cameraController!.value.aspectRatio,
                  child: CameraPreview(cameraController!),
                ),
              ),
            ),
          ),
          // Overlay UI components
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // App bar
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "Cow Recognizer Module",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Capture button and results
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await captureAndProcessImage();
                      if (faceEmbeddings == [] && noseEmbeddings == []){
                        showSnackBar(context, Colors.redAccent, "Error getting embeddings from image! \n Try again");
                      } else
                      {
                         showSnackBar(context, Colors.greenAccent, "Successful");

                         Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (context) => CreateCowPageCopy(
                               image: pngFile,
                               faceEmbeddings: faceEmbeddings,
                               noseEmbeddings: noseEmbeddings,
                             ),
                           ),
                         );
                      }
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text("Add Cow"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await captureAndProcessImage().then((_){
                        if (faceEmbeddings == [] && noseEmbeddings == []){
                          showSnackBar(context, Colors.redAccent, "Error getting embeddings from image! \n Try again");
                        } else
                        {
                          showSnackBar(context, Colors.greenAccent, "Successful");
                        }
                        similarityChecker.checkSimilarity(
                          faceEmbeddings: faceEmbeddings,
                          noseEmbeddings: noseEmbeddings,
                          threshold: 0.85,
                        ).then((match){
                          if (match == null){
                            showSnackBar(context, Colors.redAccent, "No match found! \n Try again");
                          } else {
                            showSnackBar(context, Colors.greenAccent, "Match found! \n ${match["id"]}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CowProfilePage(
                                    docId: match["id"],
                                ),
                              ),
                            );
                            print(match);
                          }
                        });
                      });

                    },
                    icon: const Icon(Icons.search),
                    label: const Text("Identify Cow"),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


}
