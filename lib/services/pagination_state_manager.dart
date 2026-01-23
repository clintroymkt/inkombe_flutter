class PaginationState<T> {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final dynamic lastDocument; // Could be DocumentSnapshot or local key
  final String? error;
  final bool isInitialLoad;

  const PaginationState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.lastDocument,
    this.error,
    this.isInitialLoad = true,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? hasMore,
    dynamic lastDocument,
    String? error,
    bool? isInitialLoad,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      error: error ?? this.error,
      isInitialLoad: isInitialLoad ?? this.isInitialLoad,
    );
  }

  bool get hasError => error != null;
  bool get isEmpty => items.isEmpty && !isLoading;
  int get itemCount => items.length;

  @override
  String toString() {
    return 'PaginationState(items: ${items.length}, isLoading: $isLoading, hasMore: $hasMore, hasError: $hasError)';
  }
}