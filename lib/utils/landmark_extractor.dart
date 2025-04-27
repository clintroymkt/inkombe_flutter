import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imgLib;

class LandMarkModelRunner {
  Interpreter? _interpreter;
  static const int BATCH_SIZE = 3;
  static const int IMAGE_SIZE = 120;
  static const int CHANNELS = 3;

  bool _isInitialized = false;
  bool _isDisposed = false;
  final Completer<void> _initializationCompleter = Completer<void>();

  /// Constructor to load the model
  LandMarkModelRunner() {
    _loadModel();
  }

  /// Load the TensorFlow Lite model
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
      debugPrint("Input details: ${_interpreter?.getInputTensors()}");
      debugPrint("Output details: ${_interpreter?.getOutputTensors()}");
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

    debugPrint("Model validation successful");
  }

  Future<List<List<List<double>>>> run(List<Uint8List> pngBytesList) async {
    if (_isDisposed) throw Exception("Model runner has been disposed");
    if (pngBytesList.length != BATCH_SIZE) {
      throw ArgumentError('Exactly $BATCH_SIZE images required');
    }

    try {
      await _initializationCompleter.future;
      if (!_isInitialized || _interpreter == null) {
        throw Exception("Interpreter is not initialized");
      }

      // 1. Prepare input
      final input = _prepareBatchInput(pngBytesList);

      // 2. Prepare outputs with proper typing
      final outputTensors = _interpreter!.getOutputTensors();
      if (outputTensors.isEmpty) throw Exception("No output tensors found");

      // Create properly typed output buffers
      final outputs = outputTensors.map((tensor) {
        final shape = tensor.shape;
        if (shape == null || shape.length < 2) {
          throw Exception("Invalid output tensor shape: $shape");
        }

        return List<List<double>>.generate(
          BATCH_SIZE,
              (_) => List<double>.filled(shape[1], 0.0),
        );
      }).toList();

      // 3. Create properly typed output map
      final outputMap = <int, Object>{};
      for (int i = 0; i < outputs.length; i++) {
        outputMap[i] = outputs[i];
      }

      // 4. Run inference
      _interpreter!.runForMultipleInputs([input], outputMap);

      return outputs;
    } catch (e, stackTrace) {
      debugPrint("Error running model: $e\n$stackTrace");
      throw Exception("Error running model: $e");
    }
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