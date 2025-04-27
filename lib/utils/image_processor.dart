import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imgLib;

import 'landmark_extractor.dart';

class ImageProcessor {
  static const int REQUIRED_IMAGE_COUNT = 3;
  static const int TARGET_IMAGE_SIZE = 120;
  static const int FACE_EMBEDDINGS_INDEX = 1;
  static const int NOSE_EMBEDDINGS_INDEX = 3;

  final LandMarkModelRunner landMarkModelRunner;

  ImageProcessor({required this.landMarkModelRunner});

  /// Processes exactly 3 images to extract face and nose embeddings
  /// Throws [ArgumentError] if not exactly 3 images are provided
  /// Throws [ImageProcessingException] for any processing errors
  Future<Map<String, dynamic>>  processThreeImages(List<XFile> imageFiles) async {
    if (imageFiles.length != REQUIRED_IMAGE_COUNT) {
      throw ArgumentError('Exactly $REQUIRED_IMAGE_COUNT images required, got ${imageFiles.length}');
    }

    try {
      // Process all images in parallel
      final pngBytesList = await Future.wait(
        imageFiles.map((file) => _prepareSingleImage(file)),
      );

      // Run model and validate outputs
      final modelOutputs = await landMarkModelRunner.run(pngBytesList);
      _validateModelOutputs(modelOutputs);

      return {
        'faceEmbeddings': modelOutputs[FACE_EMBEDDINGS_INDEX],
        'noseEmbeddings': modelOutputs[NOSE_EMBEDDINGS_INDEX],
      };
    } catch (e) {
      throw ImageProcessingException('Failed to process images: ${e.toString()}');
    }
  }

  /// Validates model outputs structure
  void _validateModelOutputs(List<List<List<double>>> outputs) {
    if (outputs.length <= NOSE_EMBEDDINGS_INDEX) {
      throw ImageProcessingException(
          'Invalid model outputs - expected at least ${NOSE_EMBEDDINGS_INDEX + 1} elements');
    }
  }

  /// Prepares single image by resizing and converting to PNG
  Future<Uint8List> _prepareSingleImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      if (bytes.isEmpty) throw Exception('Empty image file');

      final decodedImage = imgLib.decodeImage(bytes);
      if (decodedImage == null) throw Exception('Failed to decode image');

      // Validate minimum dimensions
      if (decodedImage.width < 30 || decodedImage.height < 30) {
        throw Exception('Image too small (${decodedImage.width}x${decodedImage.height})');
      }

      final resizedImage = imgLib.copyResizeCropSquare(
        decodedImage,
        TARGET_IMAGE_SIZE,
      );

      return Uint8List.fromList(imgLib.encodePng(resizedImage));
    } catch (e) {
      throw ImageProcessingException(
          'Failed to process image ${imageFile.name}: ${e.toString()}');
    }
  }
}

class ImageProcessingException implements Exception {
  final String message;
  ImageProcessingException(this.message);
  @override
  String toString() => 'ImageProcessingException: $message';
}