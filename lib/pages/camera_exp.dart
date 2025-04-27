// import 'package:adv_camera/adv_camera.dart';
// import 'package:flutter/material.dart';
//
// class CameraExp extends StatefulWidget {
//   const CameraExp({Key? key}) : super(key: key);
//
//   @override
//   _CameraExpState createState() => _CameraExpState();
// }
//
// class _CameraExpState extends State<CameraExp> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       body: const Center(child: Text('Press Floating Button to access camera')),
//       floatingActionButton: FloatingActionButton(
//         heroTag: "test3",
//         child: const Icon(Icons.camera),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (BuildContext context) {
//                 return const CameraApp();
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class CameraApp extends StatefulWidget {
//   const CameraApp({Key? key}) : super(key: key);
//
//   @override
//   _CameraAppState createState() => _CameraAppState();
// }
//
// class _CameraAppState extends State<CameraApp> {
//   List<String> pictureSizes = <String>[];
//   String? imagePath;
//   AdvCameraController? cameraController;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AdvCamera Example'),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             AdvCamera(
//               initialCameraType: CameraType.rear,
//               onCameraCreated: _onCameraCreated,
//               onImageCaptured: (String path) {
//                 if (mounted) {
//                   setState(() {
//                     imagePath = path;
//                   });
//                 }
//               },
//               cameraPreviewRatio: CameraPreviewRatio.r16_9,
//               focusRectColor: Colors.purple,
//               focusRectSize: 200,
//             ),
//             // Overlay for 200x200 boundary
//             Center(
//               child: Container(
//                 width: 200,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Colors.red,
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         heroTag: "capture",
//         child: const Icon(Icons.camera),
//         onPressed: () {
//           if (cameraController != null) {
//             cameraController!.captureImage();
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Camera is not ready yet!')),
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   void _onCameraCreated(AdvCameraController controller) {
//     setState(() {
//       cameraController = controller;
//     });
//
//     cameraController!.getPictureSizes().then((pictureSizes) {
//       setState(() {
//         this.pictureSizes = pictureSizes ?? <String>[];
//       });
//     });
//   }
// }