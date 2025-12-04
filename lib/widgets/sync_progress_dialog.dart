import 'package:flutter/material.dart';

/// A progress dialog that displays real-time synchronization progress.
///
/// This widget shows detailed statistics during data sync operations including:
/// - Total records to process
/// - Successfully synced records
/// - Failed records with retry capability
/// - Skipped records (already in sync)
/// - Real-time progress percentage
/// - Estimated time remaining
///
/// The dialog can be closed at any time without interrupting the sync operation.
///
/// Callback Parameters:
/// - `onProgress`: Total records processed so far (including all categories)
/// - `onSynced`: Records successfully synced to remote server
/// - `onFailed`: Records that failed to sync (needs retry)
/// - `onSkipped`: Records already in sync (skipped to save bandwidth)
///
/// Example Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => SyncProgressDialog(
///     totalRecords: records.length,
///     syncFunction: (progress, synced, failed, skipped) async {
///       for (int i = 0; i < records.length; i++) {
///         // Your sync logic here
///         if (syncSuccessful) {
///           synced(1); // Increment synced count
///         } else if (alreadySynced) {
///           skipped(1); // Increment skipped count
///         } else {
///           failed(1); // Increment failed count
///         }
///         progress(i + 1); // Update total progress
///       }
///     },
///   ),
/// );
/// ```
class SyncProgressDialog extends StatefulWidget {
  /// Total number of records to be processed.
  final int totalRecords;

  /// The synchronization function to execute.
  ///
  /// This function receives four callbacks:
  /// 1. `onProgress(int)`: Update total processed count
  /// 2. `onSynced(int)`: Update successfully synced count
  /// 3. `onFailed(int)`: Update failed records count
  /// 4. `onSkipped(int)`: Update skipped records count
  final Future<void> Function(
      void Function(int) onProgress,
      void Function(int) onSynced,
      void Function(int) onFailed,
      void Function(int) onSkipped,
      )? syncFunction;

  /// Creates a synchronization progress dialog.
  ///
  /// @param key The widget key
  /// @param totalRecords Total records to process (required)
  /// @param syncFunction The async function that performs the sync (optional)
  const SyncProgressDialog({
    super.key,
    required this.totalRecords,
    this.syncFunction,
  });

  @override
  State<SyncProgressDialog> createState() => _SyncProgressDialogState();
}

class _SyncProgressDialogState extends State<SyncProgressDialog> {
  int _processedRecords = 0;
  int _syncedRecords = 0;
  int _failedRecords = 0;
  int _skippedRecords = 0;
  double _progress = 0.0;
  bool _isSyncing = true;
  bool _isComplete = false;
  String _currentStatus = 'Preparing sync...';
  List<String> _errorMessages = [];

  @override
  void initState() {
    super.initState();
    _startSync();
  }

  /// Starts the synchronization process.
  ///
  /// This method calls the provided syncFunction with four callbacks
  /// that update the progress statistics in real-time.
  void _startSync() async {
    if (widget.syncFunction != null) {
      try {
        await widget.syncFunction!(
          // Update total processed records
              (progress) {
            if (mounted) {
              setState(() {
                _processedRecords = progress;
                _progress = widget.totalRecords > 0
                    ? progress / widget.totalRecords
                    : 0.0;
                _currentStatus = 'Processing record $progress of ${widget.totalRecords}';
              });
            }
          },
          // Update successfully synced records
              (synced) {
            if (mounted) {
              setState(() {
                _syncedRecords = synced;
              });
            }
          },
          // Update failed records
              (failed) {
            if (mounted) {
              setState(() {
                _failedRecords = failed;
              });
            }
          },
          // Update skipped records
              (skipped) {
            if (mounted) {
              setState(() {
                _skippedRecords = skipped;
              });
            }
          },
        );

        if (mounted) {
          setState(() {
            _isSyncing = false;
            _isComplete = true;
            _currentStatus = _failedRecords > 0
                ? 'Sync completed with ${_failedRecords} error(s)'
                : 'Sync complete!';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSyncing = false;
            _isComplete = false;
            _currentStatus = 'Sync failed: ${e.toString()}';
            _errorMessages.add(e.toString());
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          _getStatusIcon(),
          const SizedBox(width: 12),
          Text(_getTitle()),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status message
          Text(_currentStatus),
          const SizedBox(height: 16),

          // Progress bar with percentage
          _buildProgressBar(),
          const SizedBox(height: 8),

          // Statistics section
          _buildStatisticsSection(),
          const SizedBox(height: 16),

          // Estimated time remaining (if syncing)
          if (_isSyncing && _processedRecords > 0)
            Text(
              'Estimated time remaining: ${_calculateTimeRemaining()}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

          // Error messages (if any)
          if (_errorMessages.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildErrorSection(),
          ],
        ],
      ),
      actions: _buildDialogActions(),
    );
  }

  /// Returns the appropriate status icon based on sync state.
  Widget _getStatusIcon() {
    if (_isComplete) {
      return Icon(
        _failedRecords > 0 ? Icons.warning : Icons.check_circle,
        color: _failedRecords > 0 ? Colors.orange : Colors.green,
      );
    } else if (_isSyncing) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      return const Icon(Icons.error, color: Colors.red);
    }
  }

  /// Returns the appropriate dialog title based on sync state.
  String _getTitle() {
    if (_isComplete) {
      return _failedRecords > 0 ? 'Sync Completed with Issues' : 'Sync Complete';
    } else if (_isSyncing) {
      return 'Sync in Progress';
    } else {
      return 'Sync Failed';
    }
  }

  /// Builds the progress bar with percentage overlay.
  Widget _buildProgressBar() {
    return Stack(
      children: [
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            _isComplete
                ? (_failedRecords > 0 ? Colors.orange : Colors.green)
                : Colors.blue,
          ),
          minHeight: 30,
          borderRadius: BorderRadius.circular(15),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              '${(_progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the statistics section showing sync breakdown.
  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '$_processedRecords/${widget.totalRecords} records',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Success/Failure/Skipped breakdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem('Synced', _syncedRecords, Colors.green),
            _buildStatItem('Failed', _failedRecords, Colors.red),
            _buildStatItem('Skipped', _skippedRecords, Colors.blue),
          ],
        ),

        // Stats summary
        if (_processedRecords > 0) ...[
          const SizedBox(height: 8),
          Text(
            'Success rate: ${_calculateSuccessRate()}%',
            style: TextStyle(
              fontSize: 11,
              color: _calculateSuccessRate() > 90 ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds a single statistic item with colored indicator.
  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Builds the error messages section.
  Widget _buildErrorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Errors:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          constraints: const BoxConstraints(maxHeight: 80),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _errorMessages.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• ${_errorMessages[index]}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the dialog action buttons.
  List<Widget> _buildDialogActions() {
    final actions = <Widget>[
      // Close button
      TextButton(
        onPressed: () {
          Navigator.of(context).pop({
            'synced': _syncedRecords,
            'failed': _failedRecords,
            'skipped': _skippedRecords,
            'successRate': _calculateSuccessRate(),
          });
        },
        child: Text(_isComplete ? 'Close' : 'Close (Sync continues)'),
      ),
    ];

    // Add retry button if sync failed
    if (!_isSyncing && !_isComplete) {
      actions.add(
        TextButton(
          onPressed: () {
            setState(() {
              _processedRecords = 0;
              _syncedRecords = 0;
              _failedRecords = 0;
              _skippedRecords = 0;
              _progress = 0.0;
              _isSyncing = true;
              _isComplete = false;
              _currentStatus = 'Retrying sync...';
              _errorMessages.clear();
            });
            _startSync();
          },
          child: const Text('Retry'),
        ),
      );
    }

    // Add view details button if there are errors
    if (_failedRecords > 0 && _errorMessages.isNotEmpty) {
      actions.insert(
        1,
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error Details'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _errorMessages.map((error) => Text('• $error')).toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: const Text('View Details'),
        ),
      );
    }

    return actions;
  }

  /// Calculates the success rate percentage.
  double _calculateSuccessRate() {
    if (_processedRecords == 0) return 0.0;
    return (_syncedRecords / _processedRecords * 100);
  }

  /// Calculates estimated time remaining based on current progress.
  String _calculateTimeRemaining() {
    if (_processedRecords == 0 || !_isSyncing) return 'Calculating...';

    final recordsPerSecond = _processedRecords / 5; // Estimate based on 5 seconds elapsed
    final remainingRecords = widget.totalRecords - _processedRecords;

    if (recordsPerSecond <= 0) return 'Calculating...';

    final secondsRemaining = (remainingRecords / recordsPerSecond).ceil();

    if (secondsRemaining > 3600) {
      return '${(secondsRemaining / 3600).ceil()} hours';
    } else if (secondsRemaining > 60) {
      return '${(secondsRemaining / 60).ceil()} minutes';
    } else {
      return '$secondsRemaining seconds';
    }
  }
}