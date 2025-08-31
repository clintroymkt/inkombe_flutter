import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:inkombe_flutter/utils/image_processor_for_identify.dart';
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
  bool isProcessing = false;
  late LandMarkModelRunner landMarkModelRunner;
  late ImageProcessor imageProcessor;
  late ImageProcessorID imageProcessorID;
  CosineSimilarityCheck similarityChecker = CosineSimilarityCheck();

  // Image capture state
  int imagesCaptured = 0;
  List<XFile> capturedImages = [];
  List<File> pngFilesList = [];
  List<List<double>> faceEmbeddingsList = [];
  List<List<double>> noseEmbeddingsList = [];

  // UI state
  String status = 'Capture Cow';
  String result = '';

  @override
  void initState() {
    super.initState();
    landMarkModelRunner = LandMarkModelRunner();
    imageProcessor = ImageProcessor(landMarkModelRunner: landMarkModelRunner);
    imageProcessorID = ImageProcessorID(landMarkModelRunner: landMarkModelRunner);
    initCamera();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    landMarkModelRunner.dispose();
    super.dispose();
  }

  Future<void> initCamera() async {
    try {
      cameraController = CameraController(
        cameras![0],
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      await cameraController!.initialize().then((_) {
        if (!mounted) return;
        cameraController!.setFocusMode(FocusMode.auto);
        setState(() {});
      });
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }
  }

  Future<void> captureImage() async {
    if (isProcessing ||
        cameraController == null ||
        !cameraController!.value.isInitialized ||
        imagesCaptured >= 3) return;

    setState(() {
      isProcessing = true;
      result = "Capturing image ${imagesCaptured + 1}/3...";
    });

    try {
      final imageFile = await cameraController!.takePicture();
      capturedImages.add(imageFile);
      imagesCaptured++;

      setState(() {
        status = 'Capture Cow ($imagesCaptured/3)';
        result = "Captured $imagesCaptured/3 images";
      });

      if (imagesCaptured == 3) {
        await processCapturedImages();
      }
    } catch (e) {
      setState(() => result = "Capture failed: ${e.toString()}");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> processCapturedImages() async {
    setState(() {
      isProcessing = true;
      result = "Processing 3 images...";
    });

    try {
      final output = await imageProcessor.processThreeImages(capturedImages);
      pngFilesList = await Future.wait(capturedImages.map(
            (xfile) async => File(xfile.path),
      ));

      setState(() {
        faceEmbeddingsList = output["faceEmbeddings"];
        noseEmbeddingsList = output["noseEmbeddings"];
        result = "Processing complete!";
      });

      if (faceEmbeddingsList.isNotEmpty && noseEmbeddingsList.isNotEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateCowPageCopy(
              pngFilesList: pngFilesList,
              faceEmbeddingsList: faceEmbeddingsList,
              noseEmbeddingsList: noseEmbeddingsList,
            ),
          ),
        );
        resetCaptureState();
      }
    } catch (e) {
      setState(() => result = "Processing error: ${e.toString()}");
      debugPrint(e.toString());
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> identifyCow() async {
    if (capturedImages.isEmpty) return;

    setState(() {
      isProcessing = true;
      result = "Identifying cow...";
    });

    try {
      final output = await imageProcessorID.processImage(capturedImages.first);
      final matches = await similarityChecker.checkSimilarity(
        faceEmbeddingsList: [output["faceEmbeddings"]],
        noseEmbeddingsList: [output["noseEmbeddings"]],
      );

      if (matches.isNotEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CowProfilePage(docId: matches.first["id"]),
          ),
        );
      } else {
        showSnackBar(context, Colors.redAccent, "No match found");
      }
    } catch (e) {
      debugPrint("Identification error: $e");
      showSnackBar(context, Colors.redAccent, "Identification failed");
    } finally {
      setState(() {
        isProcessing = false;
        result = "";
      });
    }
  }

  void resetCaptureState() {
    setState(() {
      imagesCaptured = 0;
      capturedImages.clear();
      status = 'Capture Cow';
      result = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (cameraController != null && cameraController!.value.isInitialized)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: cameraController!.value.aspectRatio,
                child: CameraPreview(cameraController!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Capture guidance overlay
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withOpacity(0.8), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          if (capturedImages.isNotEmpty)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: capturedImages.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(capturedImages[index].path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(result),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.cameraswitch),
                  onPressed: () {
                    // Implement camera switching if needed
                  },
                ),
              ],
            ),
          ),

          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),

                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: imagesCaptured < 3 ? captureImage : null,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(status),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF064151),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (capturedImages.isNotEmpty)
                          FloatingActionButton(
                            heroTag: 'searchButton', // Unique hero tag
                            onPressed: identifyCow,
                            backgroundColor: Colors.green,
                            child: const Icon(Icons.search),
                          ),
                        if (capturedImages.isNotEmpty)
                          FloatingActionButton(
                            heroTag: 'resetButton', // Unique hero tag
                            onPressed: resetCaptureState,
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.refresh),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ),

              if (isProcessing) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}