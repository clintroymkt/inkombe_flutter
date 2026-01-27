import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'cattle_record.dart';
import 'cattle_repository.dart';
import 'network_service.dart';

class CattleSyncService {
  // Process all pending sync operations

  // Process all pending sync operations
  static Future<void> processSyncToCloudQueue() async {
    if (!await NetworkService.isOnline()) return;

    final queueItems = CattleRepository.getSyncQueueBox()?.keys.toList() ?? [];
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    for (final cattleId in queueItems) {
      // Check ownership before processing
      final localData = CattleRepository.getCattleBox()?.get(cattleId);
      if (localData != null) {
        final record =
            CattleRecord.fromJson(Map<String, dynamic>.from(localData));
        if (record.ownerUid != currentUser.uid) {
          // Skip records not owned by current user
          continue;
        }
      }

      final queueItem = CattleRepository.getSyncQueueBox()?.get(cattleId);
      if (queueItem != null) {
        final attempts = queueItem['attempts'] ?? 0;

        if (attempts < 3) {
          // Max 3 attempts
          final state =
              await CattleRepository().syncCattleToCloudRecord(cattleId);

          if (state == 'failed' && attempts >= 2) {
            await _notifySyncFailure(cattleId);
          }
        } else {
          // Too many failures, handle accordingly
          await _handleFailedSync(cattleId, queueItem);
        }
      }
    }
  }

  // Store cattle record locally
  static Future<void> _storeCattleLocally(CattleRecord record) async {
    await CattleRepository.getCattleBox()?.put(record.id, record.toJson());
  }

  // Notify user of sync failure
  static Future<void> _notifySyncFailure(String cattleId) async {
    debugPrint('Sync failed after 3 attempts for cattle: $cattleId');
    // You can implement notification logic here
  }

  // Handle failed sync after max attempts
  static Future<void> _handleFailedSync(
      String cattleId, Map<dynamic, dynamic> queueItem) async {
    debugPrint('Moving cattle $cattleId to failed sync queue');
    await CattleRepository.getSyncQueueBox()?.put(cattleId, {
      ...queueItem,
      'status': 'failed',
      'lastAttempt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Memory cache
  static List<CattleRecord>? _cachedCattle;
  static DateTime? _lastCacheTime;
  static const Duration _cacheValidity = Duration(minutes: 5);

  static void clearCache() {
    _cachedCattle = null;
    _lastCacheTime = null;
  }

  // Get all cattle records (offline-first)
  static Future<List<CattleRecord>> getAllMergedCattle(
      {bool forceRefresh = false}) async {
    // Check cache
    if (!forceRefresh &&
        _cachedCattle != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < _cacheValidity) {
      return _cachedCattle!;
    }

    String? userId = FirebaseAuth.instance.currentUser!.uid;
    final localCattle = await _getLocalCattle(userId);

    List<CattleRecord> result;
    if (await NetworkService.isOnline()) {
      try {
        // Try to get fresh data from Firestore
        final onlineCattle = await _getOnlineCattle();
        // Merge strategies: prefer online data, but keep unsynced local changes
        result = _mergeCattleRecords(localCattle, onlineCattle);
      } catch (e) {
        debugPrint('Failed to fetch online cattle: $e');
        // Fall back to local data
        result = localCattle;
      }
    } else {
      result = localCattle;
    }

    // Update cache
    _cachedCattle = result;
    _lastCacheTime = DateTime.now();
    return result;
  }

  // Get local cattle records
  static Future<List<CattleRecord>> _getLocalCattle(String ownerUid) async {
    final box = CattleRepository.getCattleBox();
    if (box == null) return [];

    final allKeys = box.keys.toList();
    final cattleList = <CattleRecord>[];

    for (final key in allKeys) {
      final data = box.get(key);
      if (data != null) {
        final cattle = CattleRecord.fromJson(Map<String, dynamic>.from(data));

        // Filter by ownerUid if provided
        if (cattle.ownerUid == ownerUid) {
          cattleList.add(cattle);
        }
      }
    }

    print(cattleList.length);
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
      // print(data['image']);
      // print(data['imageUrls']);
      // print(data['localImagePaths']);

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
        final localCattle =
            CattleRecord.fromJson(Map<String, dynamic>.from(localData));

        // Verify ownership
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && localCattle.ownerUid != currentUser.uid) {
          return null;
        }

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
          final docSnapshot =
              await cattleRepository.cattleCollection.doc(cowId).get();

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
              final localCattle =
                  CattleRecord.fromJson(Map<String, dynamic>.from(localData));
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
  static Future<int> getUnsyncedToCloudCount() async {
    final queueItems = CattleRepository.getSyncQueueBox()?.keys.toList() ?? [];
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return 0;

    int count = 0;
    for (final cattleId in queueItems) {
      final localData = CattleRepository.getCattleBox()?.get(cattleId);
      if (localData != null) {
        final record =
            CattleRecord.fromJson(Map<String, dynamic>.from(localData));
        if (record.ownerUid == currentUser.uid) {
          count++;
        }
      }
    }
    return count;
  }

  // Clear all sync queues (for testing/debugging)
  static Future<void> clearSyncToCloudQueue() async {
    await CattleRepository.getSyncQueueBox()?.clear();
  }

  // Force sync for a specific cattle record
  static Future<String> forceSyncToCloud(String cattleId) async {
    if (!await NetworkService.isOnline()) return 'offline';
    return await CattleRepository().syncCattleToCloudRecord(cattleId);
  }
}
