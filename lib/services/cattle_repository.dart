import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'cattle_record.dart';
import 'network_service.dart';

class CattleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final CollectionReference cattleCollection = FirebaseFirestore.instance.collection('cattle');
  final User? currentUser = FirebaseAuth.instance.currentUser;
  CollectionReference get cattleCollectionRef => cattleCollection;
  static const String _cattleBoxName = 'cattle_records';
  static const String _syncQueueBoxName = 'cattle_sync_queue';
  static Box? _cattleBox;
  static Box? _syncQueueBox;

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);


    _cattleBox = await Hive.openBox(_cattleBoxName);
    _syncQueueBox = await Hive.openBox(_syncQueueBoxName);
  }

  // Enhanced createCattle with offline support
  Future<String> createCattle({
    required String age,
    required String breed,
    required String sex,
    required String diseasesAilments,
    required String height,
    required String name,
    required String weight,
    required String imagePath, // Local file path
    required List<List<double>> faceEmbeddings,
    required List<List<double>> noseEmbeddings,
    required String date,
  }) async {
    try {
      final cattleId = 'cattle_${DateTime.now().microsecondsSinceEpoch}_${currentUser?.uid}';

      // Create cattle record
      final cattleRecord = CattleRecord(
        id: cattleId,
        age: age,
        breed: breed,
        sex: sex,
        diseasesAilments: diseasesAilments,
        height: height,
        name: name,
        weight: weight,
        imagePath: imagePath,
        faceEmbeddings: faceEmbeddings,
        noseEmbeddings: noseEmbeddings,
        date: date,
        ownerUid: currentUser?.uid,
        isSynced: false,
      );



      // 2. Store cattle record locally
      await _storeCattleLocally(cattleRecord, imagePath);

      // 3. Add to sync queue for online synchronization
      await _addToSyncQueue(cattleId);

      // 4. Try immediate sync if online
      if (await NetworkService.isOnline()) {
        await _syncCattleRecord(cattleId);
      }

      return cattleId;
    } catch (e, stack) {
      debugPrint('Error creating cattle: $e\n$stack');
      rethrow;
    }
  }

  // Store cattle record locally
  Future<void> _storeCattleLocally(CattleRecord record, String imageId) async {
    final cattleData = record.toJson();
    cattleData['localImageId'] = imageId; // Reference to cached image

    await _cattleBox?.put(record.id, cattleData);
  }

  // Add to sync queue
  Future<void> _addToSyncQueue(String cattleId) async {
    await _syncQueueBox?.put(cattleId, {
      'cattleId': cattleId,
      'action': 'create',
      'attempts': 0,
      'lastAttempt': null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Sync individual cattle record
  Future<bool> _syncCattleRecord(String cattleId) async {
    try {
      final localData = _cattleBox?.get(cattleId);
      if (localData == null) return false;

      final cattleRecord = CattleRecord.fromJson(Map<String, dynamic>.from(localData));

      // 1. Upload image to Firebase Storage if not already done
      String? imageUrl = cattleRecord.imageUrl;
      if (imageUrl == null && cattleRecord.imagePath != null) {
        final imageFile = File(cattleRecord.imagePath!);
        imageUrl = await _uploadCattleImage(imageFile, cattleId);

        // Update local record with image URL
        if (imageUrl != null) {
          // Create updated record with image URL
          final updatedRecord = CattleRecord(
            id: cattleRecord.id,
            age: cattleRecord.age,
            breed: cattleRecord.breed,
            sex: cattleRecord.sex,
            diseasesAilments: cattleRecord.diseasesAilments,
            height: cattleRecord.height,
            name: cattleRecord.name,
            weight: cattleRecord.weight,
            imagePath: cattleRecord.imagePath,
            imageUrl: imageUrl,
            faceEmbeddings: cattleRecord.faceEmbeddings,
            noseEmbeddings: cattleRecord.noseEmbeddings,
            date: cattleRecord.date,
            ownerUid: cattleRecord.ownerUid,
            isSynced: cattleRecord.isSynced,
            lastSyncAttempt: cattleRecord.lastSyncAttempt,
            syncAttempts: cattleRecord.syncAttempts,
          );

          await _storeCattleLocally(updatedRecord, localData['localImageId']);
        }
      }

      // 2. Upload cattle data to Firestore
      await cattleCollection.doc(cattleId).set(cattleRecord.toJson(), SetOptions(merge: true));

      // 3. Mark as synced and remove from queue
      await _markAsSynced(cattleId);

      return true;
    } catch (e) {
      debugPrint('Sync failed for cattle $cattleId: $e');
      await _incrementSyncAttempts(cattleId);
      return false;
    }
  }

  // Upload cattle image to Firebase Storage
  Future<String?> _uploadCattleImage(File imageFile, String cattleId) async {
    try {
      final ref = storage.ref().child('cattle_images/${currentUser?.uid}/$cattleId.jpg');
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploaded_from': 'cattle_app'},
        ),
      );

      final taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload failed: $e');
      return null;
    }
  }

  // Mark record as synced
  Future<void> _markAsSynced(String cattleId) async {
    final localData = _cattleBox?.get(cattleId);
    if (localData != null) {
      localData['isSynced'] = true;
      localData['lastSyncAttempt'] = DateTime.now().millisecondsSinceEpoch;
      await _cattleBox?.put(cattleId, localData);
    }
    await _syncQueueBox?.delete(cattleId);
  }

  // Increment sync attempts
  Future<void> _incrementSyncAttempts(String cattleId) async {
    final queueItem = _syncQueueBox?.get(cattleId);
    if (queueItem != null) {
      final attempts = (queueItem['attempts'] ?? 0) + 1;
      await _syncQueueBox?.put(cattleId, {
        ...queueItem,
        'attempts': attempts,
        'lastAttempt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Get cattle box for external access
  static Box? getCattleBox() => _cattleBox;

  // Get sync queue box for external access
  static Box? getSyncQueueBox() => _syncQueueBox;
}