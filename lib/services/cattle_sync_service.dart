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

  // Sync individual cattle record (moved from CattleRepository)
  static Future<bool> _syncCattleRecord(String cattleId) async {
    try {
      final localData = CattleRepository.getCattleBox()?.get(cattleId);
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
      final cattleRepository = CattleRepository();
      await cattleRepository.cattleCollection.doc(cattleId).set(cattleRecord.toJson(), SetOptions(merge: true));

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
  static Future<String?> _uploadCattleImage(File imageFile, String cattleId) async {
    try {
      final cattleRepository = CattleRepository();
      final ref = cattleRepository.storage.ref().child('cattle_images/${cattleRepository.currentUser?.uid}/$cattleId.jpg');
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

  // Store cattle record locally
  static Future<void> _storeCattleLocally(CattleRecord record, String imageId) async {
    final cattleData = record.toJson();
    cattleData['localImageId'] = imageId; // Reference to cached image
    await CattleRepository.getCattleBox()?.put(record.id, cattleData);
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
    // You can implement notification logic here
    // For example: show a snackbar, send local notification, or log to analytics
    debugPrint('Sync failed after 3 attempts for cattle: $cattleId');

    // Optional: You could show a notification to the user
    // ScaffoldMessenger.of(context).showSnackBar(...);
  }

  // Handle failed sync after max attempts
  static Future<void> _handleFailedSync(String cattleId, Map<dynamic, dynamic> queueItem) async {
    debugPrint('Moving cattle $cattleId to failed sync queue');

    // You could move it to a separate "failed" queue or mark it for manual intervention
    // For now, we'll just leave it in the queue but marked as failed
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
    final onlineMap = {for (var cattle in online) cattle.id!: cattle};

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
        _storeCattleLocally(onlineCattle, '');
      }
    }

    return merged;
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