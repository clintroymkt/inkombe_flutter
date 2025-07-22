import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inkombe_flutter/services/database_service.dart';

class CosineSimilarityCheck {
  /// Checks cattle similarity using weighted cosine similarity of face and nose embeddings.
  ///
  /// [faceEmbeddingsList]: List of face embeddings from the scanned image (typically 3 embeddings)
  /// [noseEmbeddingsList]: List of nose embeddings from the scanned image (typically 3 embeddings)
  /// Returns a list of matches sorted by combined similarity score
  Future<List<Map<String, dynamic>>> checkSimilarity({
    required List<List<double>> faceEmbeddingsList,
    required List<List<double>> noseEmbeddingsList,
    double faceWeight = 0.6,
    double noseWeight = 0.4,
    double highThreshold = 0.85,
    double lowThreshold = 0.7,
  }) async {
    try {
      // Validate inputs
      _validateInputs(faceEmbeddingsList, noseEmbeddingsList);

      // Fetch cattle data from Firestore
      final snapshot = await DatabaseService().getAllSingleUserCattle();
      if (snapshot.docs.isEmpty) return [];

      // Parse and filter stored cows
      final storedCows = _parseStoredCows(snapshot.docs);
      if (storedCows.isEmpty) return [];

      // Compare embeddings and get matches
      final matches = _findMatches(
        faceEmbeddingsList,
        noseEmbeddingsList,
        storedCows,
        faceWeight,
        noseWeight,
      );

      // Sort and filter results
      return _filterAndSortMatches(matches, highThreshold, lowThreshold);
    } on FirebaseException catch (e) {
      print('Firestore error: $e');
      return [];
    } catch (e) {
      print('Error in similarity check: $e');
      rethrow;
    }
  }

  /// Validates that input embeddings are not empty and have matching lengths
  void _validateInputs(
      List<List<double>> faceEmbeddingsList,
      List<List<double>> noseEmbeddingsList,
      ) {
    if (faceEmbeddingsList.isEmpty || noseEmbeddingsList.isEmpty) {
      throw StateError('Input embeddings cannot be empty');
    }
    if (faceEmbeddingsList.length != noseEmbeddingsList.length) {
      throw StateError('Face and nose embeddings must have same length');
    }
  }

  /// Parses and filters stored cows from Firestore documents
  List<Map<String, dynamic>> _parseStoredCows(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final faceEmbs = _parseEmbedding(data['faceEmbeddings']);
      final noseEmbs = _parseEmbedding(data['noseEmbeddings']);

      return {
        'id': doc.id,
        'faceEmbeddings': faceEmbs,
        'noseEmbeddings': noseEmbs,
        'fullData': data,
      };
    }).where((cow) =>
    (cow['faceEmbeddings'] as List).isNotEmpty &&
        (cow['noseEmbeddings'] as List).isNotEmpty
    ).toList();
  }

  /// Parses embeddings from Firestore data (handles both List and Map formats)
  List<List<double>> _parseEmbedding(dynamic value) {
    try {
      if (value == null) return [];

      // Handle List format (direct list of embeddings)
      if (value is List) {
        if (value.isEmpty) return [];
        // Check if it's List<List> (multiple embeddings)
        if (value.first is List) {
          return value.map<List<double>>((e) =>
              (e as List).map<double>((n) => (n as num).toDouble()).toList()
          ).toList();
        }
        // Single embedding case
        return [value.map<double>((e) => (e as num).toDouble()).toList()];
      }

      // Handle Map format (Firestore-style with keys)
      if (value is Map<String, dynamic>) {
        return value.values.map<List<double>>((e) =>
            (e as List).map<double>((n) => (n as num).toDouble()).toList()
        ).toList();
      }

      return [];
    } catch (e) {
      print('Error parsing embedding: $e');
      return [];
    }
  }

  /// Finds all potential matches by comparing embeddings
  List<Map<String, dynamic>> _findMatches(
      List<List<double>> faceEmbs,
      List<List<double>> noseEmbs,
      List<Map<String, dynamic>> storedCows,
      double faceWeight,
      double noseWeight,
      ) {
    return storedCows.map((cow) {
      final cowFaceEmbs = cow['faceEmbeddings'] as List<List<double>>;
      final cowNoseEmbs = cow['noseEmbeddings'] as List<List<double>>;

      // Find best match scores
      final faceScore = _findBestMatchScore(faceEmbs, cowFaceEmbs);
      final noseScore = _findBestMatchScore(noseEmbs, cowNoseEmbs);

      return {
        'id': cow['id'],
        'combinedSimilarity': (faceScore * faceWeight) + (noseScore * noseWeight),
        'faceSimilarity': faceScore,
        'noseSimilarity': noseScore,
        'data': cow['fullData'],
      };
    }).toList();
  }

  /// Finds the highest similarity score between all combinations of embeddings
  double _findBestMatchScore(
      List<List<double>> sourceEmbs,
      List<List<double>> targetEmbs,
      ) {
    double bestScore = 0.0;
    for (final source in sourceEmbs) {
      for (final target in targetEmbs) {
        final score = _cosineSimilarity(source, target);
        if (score > bestScore) {
          bestScore = score;
          // Early exit if we find a perfect match
          if (bestScore >= 0.99) return bestScore;
        }
      }
    }
    return bestScore;
  }

  /// Computes cosine similarity between two vectors
  double _cosineSimilarity(List<double> a, List<double> b) {
    assert(a.isNotEmpty && b.isNotEmpty, 'Vectors cannot be empty');
    assert(a.length == b.length, 'Vectors must have equal length');

    double dot = 0.0, magA = 0.0, magB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      magA += a[i] * a[i];
      magB += b[i] * b[i];
    }
    return magA == 0 || magB == 0 ? 0.0 : dot / (sqrt(magA) * sqrt(magB));
  }

  /// Filters and sorts matches based on thresholds
  List<Map<String, dynamic>> _filterAndSortMatches(
      List<Map<String, dynamic>> matches,
      double highThreshold,
      double lowThreshold,
      ) {
    matches.sort((a, b) =>
        (b['combinedSimilarity'] as double).compareTo(a['combinedSimilarity'] as double));

    final highMatches = matches.where((m) =>
    (m['combinedSimilarity'] as double) >= highThreshold).toList();

    return highMatches.isNotEmpty
        ? highMatches
        : matches.where((m) =>
    (m['combinedSimilarity'] as double) >= lowThreshold).toList();
  }
}