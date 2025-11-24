import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'cattle_record.dart';
import 'cattle_repository.dart';
import 'network_service.dart';

class CattleSyncService {
  // Process all pending sync operations
  static Future<void> processSyncQueue() async {
    if (!await NetworkService.isOnline()) return;

    final queueItems = CattleRepository.getSyncQueueBox()?.keys.toList() ?? [];

    for (final cattleId in queueItems) {
      final queueItem = CattleRepository.getSyncQueueBox()?.get(cattleId);
      if (queueItem != null) {
        final attempts = queueItem['attempts'] ?? 0;

        if (attempts < 3) { // Max 3 attempts
          final success = await _syncCattleRecord(cattleId);

          if (!success && attempts >= 2) {
            // Final attempt failed, notify user
            await _notifySyncFailure(cattleId);
          }
        } else {
          // Too many failures, handle accordingly
          await _handleFailedSync(cattleId, queueItem);
        }
      }
    }
  }

  // Sync individual cattle record
  static Future<bool> _syncCattleRecord(String cattleId) async {
    try {
      final localData = CattleRepository.getCattleBox()?.get(cattleId);
      if (localData == null) return false;

      final cattleRecord = CattleRecord.fromJson(Map<String, dynamic>.from(localData));

      // 1. Upload image to Firebase Storage if not already done
      List<String>? imageUrls = cattleRecord.imageUrls;
      if ((imageUrls == null || imageUrls.isEmpty) && cattleRecord.localImagePaths != null) {
        // Convert file paths to File objects for upload
        final List<File> imageFiles = cattleRecord.localImagePaths!
            .map((path) => File(path))
            .where((file) => file.existsSync())
            .toList();

        if (imageFiles.isNotEmpty) {
          imageUrls = await _uploadCattleImage(imageFiles, cattleId);

          // Update local record with image URL
          if (imageUrls != null && imageUrls.isNotEmpty) {
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

      // 2. Upload cattle data to Firestore (without local paths)
      final firestoreData = cattleRecord.toJson();
      firestoreData.remove('localImagePaths'); // Don't send local paths to Firestore

      final cattleRepository = CattleRepository();
      await cattleRepository.cattleCollection.doc(cattleId).set(firestoreData, SetOptions(merge: true));

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
  static Future<List<String>?> _uploadCattleImage(List<File> imageFiles, String cattleId) async {
    try {
      List<String> downloadUrls = [];
      final cattleRepository = CattleRepository();
      int count = 0;

      for (File file in imageFiles) {
        final ref = cattleRepository.storage.ref().child(
            'cattle_images/${cattleRepository.currentUser?.uid}/$cattleId _ $count.jpg'
        );
        final uploadTask = ref.putFile(
          file,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'uploaded_from': 'cattle_app'},
          ),
        );

        final taskSnapshot = await uploadTask;
        final downloadUrl = await taskSnapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
        count += 1;
      }

      return downloadUrls;
    } catch (e) {
      debugPrint('Image upload failed: $e');
      return null;
    }
  }

  // Store cattle record locally
  static Future<void> _storeCattleLocally(CattleRecord record) async {
    await CattleRepository.getCattleBox()?.put(record.id, record.toJson());
  }

  // Mark record as synced
  static Future<void> _markAsSynced(String cattleId) async {
    final localData = CattleRepository.getCattleBox()?.get(cattleId);
    if (localData != null) {
      localData['isSynced'] = true;
      localData['lastSyncAttempt'] = DateTime.now().millisecondsSinceEpoch;
      await CattleRepository.getCattleBox()?.put(cattleId, localData);
    }
    await CattleRepository.getSyncQueueBox()?.delete(cattleId);
  }

  // Increment sync attempts
  static Future<void> _incrementSyncAttempts(String cattleId) async {
    final queueItem = CattleRepository.getSyncQueueBox()?.get(cattleId);
    if (queueItem != null) {
      final attempts = (queueItem['attempts'] ?? 0) + 1;
      await CattleRepository.getSyncQueueBox()?.put(cattleId, {
        ...queueItem,
        'attempts': attempts,
        'lastAttempt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Notify user of sync failure
  static Future<void> _notifySyncFailure(String cattleId) async {
    debugPrint('Sync failed after 3 attempts for cattle: $cattleId');
    // You can implement notification logic here
  }

  // Handle failed sync after max attempts
  static Future<void> _handleFailedSync(String cattleId, Map<dynamic, dynamic> queueItem) async {
    debugPrint('Moving cattle $cattleId to failed sync queue');
    await CattleRepository.getSyncQueueBox()?.put(cattleId, {
      ...queueItem,
      'status': 'failed',
      'lastAttempt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get all cattle records (offline-first)
  static Future<List<CattleRecord>> getAllCattle() async {
    final localCattle = await _getLocalCattle();

    if (await NetworkService.isOnline()) {
      try {
        // Try to get fresh data from Firestore
        final onlineCattle = await _getOnlineCattle();

        // Merge strategies: prefer online data, but keep unsynced local changes
        return _mergeCattleRecords(localCattle, onlineCattle);
      } catch (e) {
        debugPrint('Failed to fetch online cattle: $e');
        // Fall back to local data
        return localCattle;
      }
    } else {
      return localCattle;
    }
  }

  // Get local cattle records
  static Future<List<CattleRecord>> _getLocalCattle() async {
    final allKeys = CattleRepository.getCattleBox()?.keys.toList() ?? [];
    final cattleList = <CattleRecord>[];

    for (final key in allKeys) {
      final data = CattleRepository.getCattleBox()?.get(key);
      if (data != null) {
        cattleList.add(CattleRecord.fromJson(Map<String, dynamic>.from(data)));
      }
    }

    return cattleList;
  }

  // Get online cattle records
  static Future<List<CattleRecord>> _getOnlineCattle() async {
    final cattleRepository = CattleRepository();
    final querySnapshot = await cattleRepository.cattleCollection
        .where('ownerUid', isEqualTo: cattleRepository.currentUser?.uid)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return CattleRecord.fromJson(data);
    }).toList();
  }

  // Merge local and online records
  static List<CattleRecord> _mergeCattleRecords(
      List<CattleRecord> local,
      List<CattleRecord> online,
      ) {
    final merged = <CattleRecord>[];
    final onlineMap = {for (var cattle in online) cattle.id: cattle};

    for (final localCattle in local) {
      if (onlineMap.containsKey(localCattle.id)) {
        // Prefer online data for synced records
        if (localCattle.isSynced) {
          merged.add(onlineMap[localCattle.id]!);
        } else {
          // Keep local changes for unsynced records
          merged.add(localCattle);
        }
      } else {
        // Local-only record
        merged.add(localCattle);
      }
    }

    // Add online records not present locally
    for (final onlineCattle in online) {
      if (!merged.any((c) => c.id == onlineCattle.id)) {
        merged.add(onlineCattle);

        // Cache the online record locally
        _storeCattleLocally(onlineCattle);
      }
    }

    return merged;
  }

  // Get single cow
  static Future<CattleRecord?> getSingleCow(String cowId) async {
    try {
      // 1. First check local storage (fastest, works offline)
      final localData = CattleRepository.getCattleBox()?.get(cowId);
      if (localData != null) {
        final localCattle = CattleRecord.fromJson(Map<String, dynamic>.from(localData));

        // If we have the cow locally and it's synced, return it immediately
        if (localCattle.isSynced) {
          return localCattle;
        }

        // If it's not synced but we're offline, return the local version
        if (!await NetworkService.isOnline()) {
          return localCattle;
        }
      }

      // 2. If online, try to fetch from Firestore (gets latest data)
      if (await NetworkService.isOnline()) {
        try {
          final cattleRepository = CattleRepository();
          final docSnapshot = await cattleRepository.cattleCollection.doc(cowId).get();

          if (docSnapshot.exists) {
            final data = docSnapshot.data() as Map<String, dynamic>;
            data['id'] = docSnapshot.id;
            final onlineCattle = CattleRecord.fromJson(data);

            // Cache the online record locally for future offline access
            await _storeCattleLocally(onlineCattle);

            return onlineCattle;
          } else {
            // Cow doesn't exist in Firestore, but might exist locally
            if (localData != null) {
              final localCattle = CattleRecord.fromJson(Map<String, dynamic>.from(localData));
              return localCattle; // Return local version even if not synced
            }
          }
        } catch (e) {
          debugPrint('Error fetching cow from Firestore: $e');
          // Fall back to local data if available
          if (localData != null) {
            return CattleRecord.fromJson(Map<String, dynamic>.from(localData));
          }
        }
      }

      // 3. If we reach here, return local data if available, otherwise null
      if (localData != null) {
        return CattleRecord.fromJson(Map<String, dynamic>.from(localData));
      }

      return null; // Cow not found locally or online

    } catch (e) {
      debugPrint('Error getting single cow: $e');
      return null;
    }
  }

  // Get unsynced cattle count
  static int getUnsyncedCount() {
    final queueItems = CattleRepository.getSyncQueueBox()?.keys.toList() ?? [];
    return queueItems.length;
  }

  // Clear all sync queues (for testing/debugging)
  static Future<void> clearSyncQueue() async {
    await CattleRepository.getSyncQueueBox()?.clear();
  }

  // Force sync for a specific cattle record
  static Future<bool> forceSync(String cattleId) async {
    if (!await NetworkService.isOnline()) return false;
    return await _syncCattleRecord(cattleId);
  }
}