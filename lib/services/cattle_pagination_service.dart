// lib/services/cattle_pagination_service.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:inkombe_flutter/services/pagination_state_manager.dart';
import 'cattle_repository.dart';
import 'cattle_record.dart';

class CattlePaginationService with ChangeNotifier {
  final CattleRepository _repository;

  // State
  PaginationState<CattleRecord> _state = const PaginationState();
  PaginationState<CattleRecord> get state => _state;

  // Pagination control
  final int pageSize;
  firestore.DocumentSnapshot? _lastCloudDocument;
  String? _lastLocalKey;
  bool _isLoadingMore = false;
  bool _hasInitialized = false;

  CattlePaginationService({
    CattleRepository? repository,
    this.pageSize = CattleRepository.defaultPageSize,
  }) : _repository = repository ?? CattleRepository();

  // ===========================================================================
  // PUBLIC METHODS
  // ===========================================================================

  /// Initialize and load first page
  Future<void> initialize() async {
    if (_hasInitialized) return;

    _state = _state.copyWith(
      isLoading: true,
      isInitialLoad: true,
    );
    notifyListeners();

    try {
      final result = await _repository.getCloudCattlePaginated(
        limit: pageSize,
        lastDocument: null,
        forceRefresh: false,
      );

      _lastCloudDocument = result.lastDoc;
      _lastLocalKey = result.records.isNotEmpty ? result.records.last.id : null;

      _state = _state.copyWith(
        items: result.records,
        isLoading: false,
        hasMore: result.hasMore,
        isInitialLoad: false,
      );

      _hasInitialized = true;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
        isInitialLoad: false,
      );
    }

    notifyListeners();
  }

  /// Load more items
  Future<void> loadMore() async {
    if (_isLoadingMore || !_state.hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getCloudCattlePaginated(
        limit: pageSize,
        lastDocument: _lastCloudDocument,
        forceRefresh: false,
      );

      if (result.records.isEmpty) {
        _state = _state.copyWith(hasMore: false);
      } else {
        // Merge with existing items
        final mergedItems = await _repository.mergePaginatedResults(
          existingRecords: _state.items,
          newRecords: result.records,
        );

        _lastCloudDocument = result.lastDoc;
        _lastLocalKey = result.records.isNotEmpty ? result.records.last.id : null;

        _state = _state.copyWith(
          items: mergedItems,
          hasMore: result.hasMore,
        );
      }
    } catch (e) {
      debugPrint('Error loading more: $e');
      _state = _state.copyWith(error: 'Failed to load more items');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final result = await _repository.getCloudCattlePaginated(
        limit: pageSize,
        lastDocument: null,
        forceRefresh: true,
      );

      _lastCloudDocument = result.lastDoc;
      _lastLocalKey = result.records.isNotEmpty ? result.records.last.id : null;

      _state = _state.copyWith(
        items: result.records,
        isLoading: false,
        hasMore: result.hasMore,
        error: null,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }

    notifyListeners();
  }

  /// Add new record (for real-time updates)
  void addRecord(CattleRecord record) {
    final newItems = [record, ..._state.items];
    _state = _state.copyWith(items: newItems);
    notifyListeners();
  }

  /// Update existing record
  void updateRecord(CattleRecord record) {
    final index = _state.items.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      final newItems = List<CattleRecord>.from(_state.items);
      newItems[index] = record;
      _state = _state.copyWith(items: newItems);
      notifyListeners();
    }
  }

  /// Remove record
  void removeRecord(String recordId) {
    final newItems = _state.items.where((r) => r.id != recordId).toList();
    _state = _state.copyWith(items: newItems);
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _state = const PaginationState();
    _lastCloudDocument = null;
    _lastLocalKey = null;
    _isLoadingMore = false;
    _hasInitialized = false;
    notifyListeners();
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  bool get isLoading => _state.isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _state.hasError;
  String? get error => _state.error;

  /// Check if we should load more based on scroll position
  bool shouldLoadMore(ScrollMetrics metrics) {
    if (_isLoadingMore || !_state.hasMore) return false;

    final pixels = metrics.pixels;
    final maxScroll = metrics.maxScrollExtent;
    final threshold = maxScroll * 0.8; // Load when 80% scrolled

    return pixels >= threshold;
  }

  /// Get item at index
  CattleRecord? getItemAt(int index) {
    if (index >= 0 && index < _state.items.length) {
      return _state.items[index];
    }
    return null;
  }

  /// Check if item exists
  bool containsRecord(String recordId) {
    return _state.items.any((record) => record.id == recordId);
  }
}