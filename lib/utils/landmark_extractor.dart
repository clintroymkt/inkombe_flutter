import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imgLib;

class LandMarkModelRunner {
  late final Interpreter _interpreter;

  /// Constructor to load the model
  LandMarkModelRunner() {
    _loadModel();
  }

  /// Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    try {
      final options = InterpreterOptions()..useNnApiForAndroid = true;
      _interpreter = await Interpreter.fromAsset('assets/facenosetracker.tflite'
          , options: options);
      print("Model loaded successfully.");
      print("Input tensor shape: ${_interpreter.getInputTensor(0).shape}");
      print("Input tensors: ${_interpreter.getInputTensors()}");
      print("Output tensors: ${_interpreter.getOutputTensors()}");
    } catch (e) {
      print("Error loading model: $e");
      rethrow;
    }
  }

  /// Run the model on the provided `pngBytes`
  Future<List> run(Uint8List pngBytes) async {
    try {
      // Ensure the interpreter is initialized
      if (_interpreter == null) {
        throw Exception("Interpreter is not initialized.");
      }

      // Prepare input tensor
      final input = _prepareInput(pngBytes);

      // Get output tensor shapes
      final outputShapes = _interpreter.getOutputTensors().map((tensor) => tensor.shape).toList();

      // print("Expected output shapes: $outputShapes");

      // Prepare output buffers to match model output shapes
      final outputs = outputShapes.map((shape) {
        // Create a 2D list with shape [3, 8]
        return List.generate(3, (_) => List<double>.filled(shape[1], 0.0));
      }).toList();

      // print('Outputs are $outputs \n');

      // Convert outputs list to a map
      final outputMap = {for (int i = 0; i < outputs.length; i++) i: outputs[i]};


      // Run inference
      _interpreter.runForMultipleInputs([input], outputMap);


      // Return the reshaped outputs
      return outputs; // Assuming the first output is the one you need
    } catch (e, stackTrace) {
      print("Error running model: $e \n $stackTrace");
      rethrow;
    }
  }

  /// Prepare input tensor from `pngBytes`
  List<List<List<List<double>>>> _prepareInput(Uint8List pngBytes) {
    // Decode the PNG image
    final decodedImage = imgLib.decodeImage(pngBytes);
    if (decodedImage == null) {
      throw Exception("Unable to decode image from provided bytes.");
    }

    // Resize the image to 120x120
    final resizedImage = imgLib.copyResize(decodedImage, width: 120, height: 120);

    // Normalize pixel values (0-255 to 0-1) and create a 3D list
    final normalizedImage = List.generate(
      resizedImage.height,
          (y) => List.generate(
        resizedImage.width,
            (x) {
          final pixel = resizedImage.getPixel(x, y);
          final r = imgLib.getRed(pixel) / 255.0;
          final g = imgLib.getGreen(pixel) / 255.0;
          final b = imgLib.getBlue(pixel) / 255.0;
          return [r, g, b];
        },
      ),
    );

    // Replicate the image three times to form a 4D tensor [3, 120, 120, 3]
    return List.generate(3, (_) => normalizedImage);
  }

  /// Dispose of the interpreter when done
  void dispose() {
    try {
      _interpreter.close();
    } catch (e) {
      print("Error while closing interpreter: $e");
    }
  }
}
