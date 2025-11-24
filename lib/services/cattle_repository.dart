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
    required List<File>? images,
    required List<List<double>> faceEmbeddings,
    required List<List<double>> noseEmbeddings,
    required String date,
  }) async {
    try {
      final cattleId = 'cattle_${DateTime.now().microsecondsSinceEpoch}_${currentUser?.uid}';

      // Convert File objects to file paths for local storage
      List<String>? imagePaths;
      if (images != null) {
        imagePaths = images.map((file) => file.path).toList();
      }

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
        localImagePaths: imagePaths, // Store paths instead of File objects
        faceEmbeddings: faceEmbeddings,
        noseEmbeddings: noseEmbeddings,
        date: date,
        ownerUid: currentUser?.uid,
        isSynced: false,
        imageUrls: [],
      );

      // 2. Store cattle record locally
      await _storeCattleLocally(cattleRecord);

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
  Future<void> _storeCattleLocally(CattleRecord record) async {
    await _cattleBox?.put(record.id, record.toJson());
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
      List<String>? imageUrls = cattleRecord.imageUrls;
      if ((imageUrls == null || imageUrls.isEmpty) && cattleRecord.localImagePaths != null) {
        // Convert file paths back to File objects for upload
        final List<File> imageFiles = cattleRecord.localImagePaths!
            .map((path) => File(path))
            .where((file) => file.existsSync())
            .toList();

        if (imageFiles.isNotEmpty) {
          imageUrls = await await _uploadCattleImage(imageFiles, cattleId);

          // Update local record with image URLs
          if (imageUrls != null) {
            final updatedRecord = CattleRecord(
              id: cattleRecord.id,
              age: cattleRecord.age,
              breed: cattleRecord.breed,
              sex: cattleRecord.sex,
              diseasesAilments: cattleRecord.diseasesAilments,
              height: cattleRecord.height,
              name: cattleRecord.name,
              weight: cattleRecord.weight,
              localImagePaths: cattleRecord.localImagePaths,
              imageUrls: imageUrls,
              faceEmbeddings: cattleRecord.faceEmbeddings,
              noseEmbeddings: cattleRecord.noseEmbeddings,
              date: cattleRecord.date,
              ownerUid: cattleRecord.ownerUid,
              isSynced: cattleRecord.isSynced,
              lastSyncAttempt: cattleRecord.lastSyncAttempt,
              syncAttempts: cattleRecord.syncAttempts,
            );

            await _storeCattleLocally(updatedRecord);
          }
        }
      }

      // 2. Upload cattle data to Firestore (without localImagePaths)
      final firestoreData = cattleRecord.toJson();
      firestoreData.remove('localImagePaths'); // Don't send local paths to Firestore

      await cattleCollection.doc(cattleId).set(firestoreData, SetOptions(merge: true));

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
  Future<List<String>?> _uploadCattleImage(List<File> imageFiles, String cattleId) async {
    try {
      int count = 0;
      List<String> downloadUrls = [];

      for (File file in imageFiles) {
        final ref = storage.ref().child(
            'cattle_images/${currentUser?.uid}/$cattleId _ $count.jpg');
        final uploadTask = ref.putFile(
          file,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'uploaded_from': 'cattle_app'},
          ),
        );

        final taskSnapshot = await uploadTask;
        downloadUrls.add(await taskSnapshot.ref.getDownloadURL());
        count += 1;
      }

      return downloadUrls;
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