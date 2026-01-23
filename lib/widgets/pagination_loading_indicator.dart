// lib/widgets/pagination_loading_indicator.dart

import 'package:flutter/material.dart';

class PaginationLoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final double height;

  const PaginationLoadingIndicator({
    super.key,
    this.isLoading = false,
    this.hasMore = true,
    this.onLoadMore,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMore && !isLoading) {
      return Container(
        height: height,
        alignment: Alignment.center,
        child: const Text(
          'No more items',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (isLoading) {
      return SizedBox(
        height: height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (onLoadMore != null) {
      return SizedBox(
        height: height,
        child: Center(
          child: TextButton(
            onPressed: onLoadMore,
            child: const Text('Load More'),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}



