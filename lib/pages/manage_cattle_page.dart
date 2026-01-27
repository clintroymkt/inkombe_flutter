// Your updated ManageCattlePage with pagination integration

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inkombe_flutter/services/cattle_repository.dart';
import 'package:inkombe_flutter/services/cattle_sync_service.dart';
import 'package:inkombe_flutter/services/database_service.dart';
import 'package:inkombe_flutter/services/cattle_pagination_service.dart';
import 'package:inkombe_flutter/widgets/CustomButton.dart';
import 'package:inkombe_flutter/widgets/color_theme.dart';
import 'package:inkombe_flutter/widgets/pagination_loading_indicator.dart';
import 'package:inkombe_flutter/widgets/pagination_error_widget.dart';
import 'package:inkombe_flutter/widgets/pagination_empty_state.dart';
import '../services/cattle_record.dart';
import '../widgets/list_card.dart';
import '../widgets/sync_progress_dialog.dart';

class ManageCattlePage extends StatefulWidget {
  const ManageCattlePage({super.key});

  @override
  State<ManageCattlePage> createState() => _ManageCattlePageState();
}

class _ManageCattlePageState extends State<ManageCattlePage> {
  late CattlePaginationService _paginationService;
  User? currentUser = FirebaseAuth.instance.currentUser;
  int onlineDocsCount = 0;

  final ScrollController _scrollController = ScrollController();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();

    _paginationService = CattlePaginationService(
      pageSize: 10, // Adjust as needed
    );

    // Initialize pagination
    _paginationService.initialize();

    // Setup scroll listener
    _scrollController.addListener(_onScroll);

    // Listen to pagination service changes
    _paginationService.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _paginationService.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_paginationService.shouldLoadMore(_scrollController.position)) {
      _paginationService.loadMore();
    }
  }

  // ... keep your existing syncCattleData and syncCloudToLocal methods ...
  // They remain exactly the same as in your original code

  void refreshData() {
    _paginationService.refresh();
  }

  // Helper method to get the first available image
  String? _getFirstImagePath(CattleRecord doc) {
    if (doc.localImagePaths != null && doc.localImagePaths!.isNotEmpty) {
      return doc.localImagePaths![0];
    }
    if (doc.imageUrls != null && doc.imageUrls!.isNotEmpty) {
      return doc.imageUrls![0];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: const Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header/Actions section
              Container(
                padding: const EdgeInsets.only(
                    top: 20, left: 18, right: 18, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actions',
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // CustomButton(
                        //   icon: Icons.refresh,
                        //   text: 'Refresh',
                        //   onPressed: refreshData,
                        //   backgroundColor: ThemeColors.secondary(),
                        // ),
                        CustomButton(
                          icon: Icons.cloud_upload,
                          text: 'Sync Data',
                          backgroundColor: ThemeColors.secondary(),
                          onPressed: () async {
                            final total =
                                await CattleRepository().getTotalCattleCount();
                            if (!context.mounted) return;

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => SyncProgressDialog(
                                totalRecords: total,
                                syncFunction: (onProgress, synched, failed,
                                        skipped) =>
                                    syncCattleData(
                                        onProgress, synched, failed, skipped),
                              ),
                            );
                          },
                        ),
                        CustomButton(
                          icon: Icons.cloud_download,
                          text: 'Download',
                          backgroundColor: ThemeColors.secondary(),
                          onPressed: () async {
                            final total =
                                await DatabaseService().getOnlineCattleCount();
                            setState(() {
                              onlineDocsCount = total;
                            });

                            if (!context.mounted) return;

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => SyncProgressDialog(
                                totalRecords: total,
                                syncFunction: (onProgress, synched, failed,
                                        skipped) =>
                                    syncCloudToLocal(
                                        onProgress, synched, failed, skipped),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Cattle List section
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Text(
                          'Cattle (${_paginationService.state.items.length})',
                          style: const TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Error display
                      if (_paginationService.hasError)
                        PaginationErrorWidget(
                          error: _paginationService.error!,
                          onRetry: _paginationService.refresh,
                        ),

                      // Content area
                      Expanded(
                        child: _buildContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Loading indicator for initial load
    if (_paginationService.state.isInitialLoad &&
        _paginationService.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Empty state
    if (_paginationService.state.items.isEmpty &&
        !_paginationService.isLoading) {
      return PaginationEmptyState(
        message: 'No cattle records found',
        icon: Icons.pets,
        onRetry: _paginationService.refresh,
      );
    }

    // List with pagination
    return RefreshIndicator(
      onRefresh: () async {
        await _paginationService.refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _paginationService.state.items.length +
            (_paginationService.state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading more indicator
          if (index >= _paginationService.state.items.length) {
            return PaginationLoadingIndicator(
              isLoading: _paginationService.isLoadingMore,
              hasMore: _paginationService.state.hasMore,
              onLoadMore: _paginationService.loadMore,
            );
          }

          // Cattle item
          final cattle = _paginationService.state.items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ListCard(
              title: cattle.name,
              date: cattle.date,
              imagePath: _getFirstImagePath(cattle),
              imageUri: cattle.imageUrls?.isNotEmpty == true
                  ? cattle.imageUrls![0]
                  : (cattle.image != null && cattle.image!.isNotEmpty)
                      ? cattle.image!
                      : null,
              docId: cattle.id,
            ),
          );
        },
      ),
    );
  }

  // Paste your existing syncCattleData method here
  Future<void> syncCattleData(
      void Function(int) onProgress,
      void Function(int) synced,
      void Function(int) failed,
      void Function(int) skipped) async {
    try {
      final cattleList = CattleRepository().getAllCattle();

      // Sync each cattle with progress updates
      for (int i = 0; i < cattleList.length; i++) {
        final cattle = cattleList[i];
        // debugPrint('Syncing: ${cattle.id}');

        // Your sync logic
        final state = await CattleSyncService.forceSyncToCloud(cattle.id);

        switch (state) {
          case 'synced':
            synced(i + 1);
            break;
          case 'no cattle':
          case 'failed':
            failed(i + 1);
            break;
          case 'skip':
            skipped(i + 1);
            break;
          default:
        }

        debugPrint('Sync result: $state');

        // Update progress (i+1 because we want 1-based counting)
        onProgress(i + 1);

        // Optional delay to prevent overwhelming server
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      debugPrint('Error in syncCattleData: $e');
      rethrow;
    }
  }

  // Paste your existing syncCloudToLocal method here
  Future<void> syncCloudToLocal(
    void Function(int) onProgress,
    void Function(int) synced,
    void Function(int) failed,
    void Function(int) skipped,
  ) async {
    try {
      // Get all documents from the cloud
      final querySnapshot = await DatabaseService().getAllSingleUserCattle();

      // Update the online docs count
      setState(() {
        onlineDocsCount = querySnapshot.size;
      });

      final documents = querySnapshot.docs;
      final totalDocs = documents.length;

      if (totalDocs == 0) {
        debugPrint('No documents to sync');
        return;
      }

      int syncedCount = 0;
      int failedCount = 0;
      int skippedCount = 0;

      for (int i = 0; i < documents.length; i++) {
        final doc = documents[i];

        final state =
            await CattleRepository().syncSingleCattleFromCloud(doc.id);

        switch (state) {
          case 'synced':
            syncedCount++;
            synced(syncedCount);
            break;
          case 'failed':
          case 'no found':
            failedCount++;
            failed(failedCount);
            break;
          case 'skip':
            skippedCount++;
            skipped(skippedCount);
            break;
          default:
            debugPrint('Unknown sync state: $state');
            failedCount++;
            failed(failedCount);
        }

        debugPrint('Sync result: $state for document ${doc.id}');

        // Calculate progress percentage
        onProgress(i + 1);

        // Optional: Add delay to prevent overwhelming the server
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint(
          'Sync completed: $syncedCount synced, $failedCount failed, $skippedCount skipped');
    } catch (e) {
      debugPrint('Error in syncCloudToLocal: $e');
      rethrow;
    }
  }
}
