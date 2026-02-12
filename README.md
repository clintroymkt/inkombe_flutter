# inkombe_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Run unit tests

```flutter test lib/test/sync_online_to_offline_test.dart```

## Utilities

The `lib/utils` directory contains essential helper classes and logic for the cattle identification system.

| Class | Description |
|-------|-------------|
| **`Utilities.dart`** | Contains static helper methods for formatting dates (`formatLongDateTime`, `formatShortDateTime`) and retrieving the first available image path for a cattle record, prioritizing local paths over remote URLs. |
| **`CosineSimilarityCheck.dart`** | Implements the core logic for identifying cattle. It compares input embeddings (face and nose) against stored records using weighted cosine similarity. It supports both **online** (querying Firestore) and **offline** (querying local `CattleRepository`) modes. |
| **`ImageProcessor.dart`** | Designed for the **registration** process. It accepts a specific number of images (currently 3), processes them in parallel (resize/crop), runs them through the `LandMarkModelRunner`, and returns the extracted embeddings. |
| **`ImageProcessorID.dart`** | Designed for the **identification** process. It handles a single image input, resizes it, converts it to the required format, runs inference to extract embeddings, and returns both the embeddings and the processed file. |
| **`LandMarkModelRunner.dart`** | A wrapper around the TensorFlow Lite interpreter. It loads the `facenosetracker.tflite` model, pre-processes image inputs (normalization), manages the interpreter lifecycle, and parses the raw output tensors into structured embeddings. |

## General Code Construction & Integration

The application integrates these utilities to form a complete biometric identification pipeline for cattle.

### 1. Image Capture & Processing Pipeline
The flow of data for identifying or registering a cow is as follows:

1.  **Capture**: The app uses the camera to capture images of the cow's face.
2.  **Preprocessing**: 
    - For **Registration**, `ImageProcessor` handles a batch of 3 images to ensure distinct features are captured.
    - For **Identification**, `ImageProcessorID` handles a single image for quick scanning.
    - Images are resized to **120x120** and converted to raw RGB bytes.
3.  **Inference (`LandMarkModelRunner`)**: The preprocessed bytes are passed to the `LandMarkModelRunner`, which executes the TFLite model. The model outputs vector embeddings representing the unique features of the cow's face and nose.

### 2. Similarity Matching (`CosineSimilarityCheck`)
Once embeddings are extracted, `CosineSimilarityCheck` is used to find matches:

- It retrieves existing records from **Firestore** (Online) or the local database (Offline).
- It calculates the **Cosine Similarity** between the scanned embeddings and stored embeddings.
- A weighted score (default: 60% Face, 40% Nose) is computed.
- Results are filtered by thresholds (High: 0.85, Low: 0.70) to determine a positive match.

### 3. Updating the Code

- **Model Updates**: To use a new TFLite model, replace `assets/facenosetracker.tflite` and update the input/output tensor shapes in `LandMarkModelRunner` if necessary.
- **Threshold Adjustments**: Sensitivity of matching can be tuned by modifying `highThreshold` and `lowThreshold` in `CosineSimilarityCheck`.
- **Data Model**: Changes to `CattleRecord` should be reflected in how `Utilities` parses image paths and how `CosineSimilarityCheck` reads embeddings.
