import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imgLib;

import 'landmark_extractor.dart';

class ImageProcessorID {
  late final LandMarkModelRunner landMarkModelRunner;

  ImageProcessorID({required this.landMarkModelRunner});

  /// Processes an image file and returns the embeddings and the PNG file.
  ///
  /// [imageFile]: The image file to process.
  /// Returns a map containing face embeddings, nose embeddings, and the PNG file.
  Future<Map<String, dynamic>> processImage(XFile imageFile) async {
    try {
      // Step 1: Read the image bytes
      final bytes = await imageFile.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception("Image bytes are empty. The file might be corrupted.");
      }
      print("Image bytes length: ${bytes.length}");

      // Step 2: Decode the image
      final imgLib.Image? decodedImage = imgLib.decodeImage(bytes);
      if (decodedImage == null) {
        throw Exception("Error decoding image. Check if the image format is supported.");
      }
      print("Decoded image size: ${decodedImage.width}x${decodedImage.height}");

      // Step 3: Resize the image
      final imgLib.Image resizedImage = imgLib.copyResizeCropSquare(decodedImage, 120);
      print("Resized image size: ${resizedImage.width}x${resizedImage.height}");

      // Step 4: Convert to PNG format
      final pngBytes = Uint8List.fromList(imgLib.encodePng(resizedImage));
      if (pngBytes.isEmpty) {
        throw Exception("Failed to convert resized image to PNG bytes.");
      }
      print("PNG bytes length: ${pngBytes.length}");

      // Step 5: Run the model - FIXED HERE
      final output = await landMarkModelRunner.run([pngBytes]);

      if (output.isEmpty || output.any((row) => row.isEmpty)) {
        throw Exception("Model returned empty or invalid output.");
      }
      print("Model output received: ${output.length} rows of ${output[0].length} columns.");

      // Step 6: Extract embeddings
      final faceEmbeddings = output[1][0]; // Face embeddings
      final noseEmbeddings = output[3][0]; // Nose embeddings

      // Step 7: Save the resized image to a temporary file
      final tempDir = Directory.systemTemp;
      final tempFilePath = "${tempDir.path}/resized_image.png";
      final pngFile = File(tempFilePath);
      await pngFile.writeAsBytes(pngBytes);
      print("PNG file saved at: $tempFilePath");

      // Return embeddings and the PNG file
      return {
        "faceEmbeddings": faceEmbeddings,
        "noseEmbeddings": noseEmbeddings,
        "file": pngFile, // Return the PNG file
      };
    } catch (e, stackTrace) {
      print("Error processing image: $e");
      print(stackTrace);
      rethrow; // Re-throw the exception for the caller to handle
    }
  }
}
