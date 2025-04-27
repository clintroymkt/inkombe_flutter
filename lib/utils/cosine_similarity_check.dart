import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inkombe_flutter/services/database_service.dart';

class CosineSimilarityCheck {
  /// Fetch all user cattle data and check similarity against new embeddings
  Future<List<Map<String, dynamic>>?> checkSimilarity({
    required List<List<double>> faceEmbeddingsList,
    required List<List<double>> noseEmbeddingsList,
    double faceWeight = 0.6,
    double noseWeight = 0.4,
    double highThreshold = 0.8,
    double lowThreshold = 0.7,
  }) async {
    try {
      QuerySnapshot cattleSnapshot = await DatabaseService().getAllSingleUserCattle();
      print("Fetched ${cattleSnapshot.docs.length} cows");
      if (cattleSnapshot.docs.isEmpty) {
        print("No stored cattle found.");
        return null;
      }

      List<double> getListFromFirestore(dynamic value) {
        if (value == null) return []; // Handle null case
        if (value is List) {
          return value.map((e) => (e as num).toDouble()).toList(); // Ensure numbers
        }
        return []; // If not a list, return empty
      }

      List<Map<String, dynamic>> storedCows = cattleSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          "id": doc.id,
          "faceEmbeddings": getListFromFirestore(data["faceEmbeddings"]),
          "noseEmbeddings": getListFromFirestore(data["noseEmbeddings"]),
        };
      }).toList();

      List<Map<String, dynamic>> highMatches = compareCowEmbeddings(
        newFaceEmbeddingsList: faceEmbeddingsList,
        newNoseEmbeddingsList: noseEmbeddingsList,
        storedCows: storedCows,
        faceWeight: faceWeight,
        noseWeight: noseWeight,
        threshold: highThreshold,
      );

      if (highMatches.isNotEmpty) {
        return highMatches;
      }

      List<Map<String, dynamic>> lowMatches = compareCowEmbeddings(
        newFaceEmbeddingsList: faceEmbeddingsList,
        newNoseEmbeddingsList: noseEmbeddingsList,
        storedCows: storedCows,
        faceWeight: faceWeight,
        noseWeight: noseWeight,
        threshold: lowThreshold,
      );

      return lowMatches;
    } catch (e) {
      print("Error fetching cattle data: $e");
      return null;
    }
  }

  /// Compute cosine similarity
  double cosineSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      return 1;
    }

    double dotProduct = 0.0;
    double magnitude1 = 0.0;
    double magnitude2 = 0.0;

    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      magnitude1 += embedding1[i] * embedding1[i];
      magnitude2 += embedding2[i] * embedding2[i];
    }

    magnitude1 = sqrt(magnitude1);
    magnitude2 = sqrt(magnitude2);

    if (magnitude1 == 0 || magnitude2 == 0) {
      throw ArgumentError("Embeddings cannot have zero magnitude");
    }

    return dotProduct / (magnitude1 * magnitude2);
  }

  /// Compare embeddings with stored data
  List<Map<String, dynamic>> compareCowEmbeddings({
    required List<List<double>> newFaceEmbeddingsList,
    required List<List<double>> newNoseEmbeddingsList,
    required List<Map<String, dynamic>> storedCows,
    required double faceWeight,
    required double noseWeight,
    required double threshold,
  }) {
    List<Map<String, dynamic>> matches = [];

    for (Map<String, dynamic> cow in storedCows) {
      List<double> storedFaceEmbedding = cow["faceEmbeddings"];
      List<double> storedNoseEmbedding = cow["noseEmbeddings"];

      if (storedFaceEmbedding.isEmpty || storedNoseEmbedding.isEmpty) {
        print("Skipping cow ${cow['id']} - missing embeddings");
        continue; // Skip this cow if embeddings are missing
      }

      double faceSimilarity = 0.0;
      double noseSimilarity = 0.0;

      for (int i = 0; i < newFaceEmbeddingsList.length; i++) {
        faceSimilarity += cosineSimilarity(newFaceEmbeddingsList[i], storedFaceEmbedding);
        noseSimilarity += cosineSimilarity(newNoseEmbeddingsList[i], storedNoseEmbedding);
      }

      faceSimilarity /= newFaceEmbeddingsList.length;
      noseSimilarity /= newNoseEmbeddingsList.length;

      double combinedSimilarity = (faceSimilarity * faceWeight) + (noseSimilarity * noseWeight);

      if (combinedSimilarity >= threshold) {
        matches.add({
          "id": cow["id"],
          "combinedSimilarity": combinedSimilarity,
        });
      }
    }

    return matches;
  }
}