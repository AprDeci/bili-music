enum PagedStatus { idle, loadingFirstPage, loadingMore, ready, failure }

class PagedState<T> {
  const PagedState({
    List<T>? items,
    this.status = PagedStatus.idle,
    this.page = 0,
    this.hasMore = false,
    this.errorMessage,
  }) : _items = items;

  static const Object _unset = Object();

  final List<T>? _items;
  final PagedStatus status;
  final int page;
  final bool hasMore;
  final String? errorMessage;

  List<T> get items => _items ?? const <Never>[];

  bool get isInitialLoading => status == PagedStatus.loadingFirstPage;

  bool get isLoadingMore => status == PagedStatus.loadingMore;

  bool get hasFailed => status == PagedStatus.failure;

  bool get isReady => status == PagedStatus.ready;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  PagedState<T> copyWith({
    List<T>? items,
    PagedStatus? status,
    int? page,
    bool? hasMore,
    Object? errorMessage = _unset,
  }) {
    return PagedState<T>(
      items: items ?? _items,
      status: status ?? this.status,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  PagedState<T> startingFirstPage() {
    return copyWith(status: PagedStatus.loadingFirstPage, errorMessage: null);
  }

  PagedState<T> startingNextPage() {
    return copyWith(status: PagedStatus.loadingMore, errorMessage: null);
  }

  PagedState<T> withFirstPage(
    List<T> nextItems, {
    required int page,
    required bool hasMore,
  }) {
    return PagedState<T>(
      items: List<T>.unmodifiable(nextItems),
      status: PagedStatus.ready,
      page: page,
      hasMore: hasMore,
    );
  }

  PagedState<T> withNextPage(
    List<T> nextItems, {
    required int page,
    required bool hasMore,
  }) {
    return PagedState<T>(
      items: List<T>.unmodifiable(<T>[...items, ...nextItems]),
      status: PagedStatus.ready,
      page: page,
      hasMore: hasMore,
    );
  }

  PagedState<T> failed(Object error) {
    return copyWith(
      status: PagedStatus.failure,
      errorMessage: error.toString(),
    );
  }

  PagedState<T> reset() {
    return PagedState<T>(page: page, hasMore: hasMore);
  }
}
