import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imgLib;

class LandMarkModelRunner {
  Interpreter? _interpreter;
  static const int BATCH_SIZE = 3;  // Model expects exactly 3 images
  static const int IMAGE_SIZE = 120;
  static const int CHANNELS = 3;

  bool _isInitialized = false;
  bool _isDisposed = false;
  final Completer<void> _initializationCompleter = Completer<void>();

  LandMarkModelRunner() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    if (_isDisposed) return;

    try {
      final options = InterpreterOptions()..useNnApiForAndroid = true;
      _interpreter = await Interpreter.fromAsset(
        'assets/facenosetracker.tflite',
        options: options,
      );
      _validateModel();
      _isInitialized = true;
      _initializationCompleter.complete();
      debugPrint("Model loaded successfully");
    } catch (e, stackTrace) {
      _initializationCompleter.completeError(e);
      debugPrint("Failed to load model: $e\n$stackTrace");
      throw Exception("Failed to load model: $e");
    }
  }

  void _validateModel() {
    if (_interpreter == null) throw Exception("Interpreter is null");
    final inputTensors = _interpreter!.getInputTensors();
    if (inputTensors.isEmpty) throw Exception("No input tensors found");
    final outputTensors = _interpreter!.getOutputTensors();
    if (outputTensors.isEmpty) throw Exception("No output tensors found");
  }

  /// Runs the model with 1-3 images, duplicating images as needed to make 3
  Future<List<List<List<double>>>> run(List<Uint8List> pngBytesList) async {
    if (_isDisposed) throw Exception("Model runner has been disposed");
    if (pngBytesList.isEmpty || pngBytesList.length > BATCH_SIZE) {
      throw ArgumentError('Between 1 and $BATCH_SIZE images required');
    }

    await _initializationCompleter.future;
    if (!_isInitialized || _interpreter == null) {
      throw Exception("Interpreter is not initialized");
    }

    // Prepare the batch by duplicating images if needed
    final preparedBatch = _prepareInputBatch(pngBytesList);
    final input = _prepareBatchInput(preparedBatch);

    // Prepare output buffers
    final outputTensors = _interpreter!.getOutputTensors();
    final outputs = outputTensors.map((tensor) {
      return List<List<double>>.generate(
        BATCH_SIZE,
            (_) => List<double>.filled(tensor.shape[1], 0.0),
      );
    }).toList();

    // Run inference
    final outputMap = <int, Object>{};
    for (int i = 0; i < outputs.length; i++) {
      outputMap[i] = outputs[i];
    }

    _interpreter!.runForMultipleInputs([input], outputMap);

    // Return only the unique results (not the duplicates)
    return _filterDuplicateResults(outputs, pngBytesList.length);
  }

  /// Expands the input list to exactly 3 images by duplicating as needed
  List<Uint8List> _prepareInputBatch(List<Uint8List> originalImages) {
    if (originalImages.length == BATCH_SIZE) return originalImages;

    final preparedBatch = <Uint8List>[];
    preparedBatch.addAll(originalImages);

    // Handle case with 1 image (duplicate it twice)
    if (originalImages.length == 1) {
      preparedBatch.add(originalImages[0]);
      preparedBatch.add(originalImages[0]);
    }
    // Handle case with 2 images (duplicate the second one)
    else if (originalImages.length == 2) {
      preparedBatch.add(originalImages[1]);
    }

    return preparedBatch;
  }

  /// Filters out duplicate results when we had to duplicate inputs
  List<List<List<double>>> _filterDuplicateResults(
      List<List<List<double>>> allResults, int originalCount) {
    if (originalCount == BATCH_SIZE) return allResults;

    return allResults.map((output) {
      return output.sublist(0, originalCount);
    }).toList();
  }

  List<List<List<List<double>>>> _prepareBatchInput(List<Uint8List> pngBytesList) {
    return pngBytesList.map((pngBytes) {
      final decodedImage = imgLib.decodeImage(pngBytes);
      if (decodedImage == null) throw Exception("Failed to decode image");

      final resizedImage = imgLib.copyResize(
        decodedImage,
        width: IMAGE_SIZE,
        height: IMAGE_SIZE,
      );

      return List.generate(
        IMAGE_SIZE,
            (y) => List.generate(
          IMAGE_SIZE,
              (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              imgLib.getRed(pixel) / 255.0,
              imgLib.getGreen(pixel) / 255.0,
              imgLib.getBlue(pixel) / 255.0,
            ];
          },
        ),
      );
    }).toList();
  }

  void dispose() {
    if (_isInitialized && !_isDisposed && _interpreter != null) {
      _interpreter!.close();
      _interpreter = null;
      _isDisposed = true;
      _isInitialized = false;
    }
  }
}