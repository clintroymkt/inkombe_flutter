// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:inkombe_flutter/widgets.dart';
// import '../utils/cosine_similarity_check.dart';
// import '../utils/landmark_extractor.dart';
// import '../main.dart';
// import 'cow_profile_page.dart';
// import 'create_cow_page_copy.dart';
// import '../utils/image_processor.dart';
//
// class NewScanPage extends StatefulWidget {
//   const NewScanPage({super.key});
//
//   @override
//   State<NewScanPage> createState() => _NewScanPageState();
// }
//
// class _NewScanPageState extends State<NewScanPage> {
//   CameraController? cameraController;
//   bool isProcessing = false;
//   late LandMarkModelRunner landMarkModelRunner;
//   late ImageProcessor imageProcessor;
//   CosineSimilarityCheck similarityChecker = CosineSimilarityCheck();
//
//   @override
//   void initState() {
//     super.initState();
//     landMarkModelRunner = LandMarkModelRunner();
//     imageProcessor = ImageProcessorID(landMarkModelRunner: landMarkModelRunner);
//     initCamera();
//   }
//
//   @override
//   void dispose() {
//     cameraController?.dispose();
//     landMarkModelRunner.dispose();
//     super.dispose();
//   }
//
//   void initCamera() async {
//     cameraController = CameraController(
//       cameras![0],
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );
//
//     await cameraController!.initialize();
//     await cameraController!.setFocusMode(FocusMode.auto);
//
//     if (!mounted) return;
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           cameraController == null || !cameraController!.value.isInitialized
//               ? Container(
//             color: Colors.black,
//             child: const Center(
//               child: Icon(Icons.photo_camera_front, color: Colors.amberAccent, size: 40.0),
//             ),
//           )
//               : CameraPreview(cameraController!),
//
//           // Center Overlay
//           Center(
//             child: Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.green, width: 2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//
//           // Capture button
//           Positioned(
//             bottom: 50,
//             left: 0,
//             right: 0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: captureAndProcessImage,
//                   icon: const Icon(Icons.camera),
//                   label: const Text("Add Cow"),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> captureAndProcessImage() async {
//     if (cameraController == null || !cameraController!.value.isInitialized) {
//       print("Camera is not initialized.");
//       return;
//     }
//
//     try {
//       XFile imageFile = await cameraController!.takePicture();
//       print("Image captured at path: ${imageFile.path}");
//       // Process the image...
//     } catch (e) {
//       print("Error capturing image: $e");
//     }
//   }
// }
