import 'package:bilimusic/common/domain/paged_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PagedState', () {
    test('初始态为空且无更多', () {
      const PagedState<int> state = PagedState<int>();

      expect(state.items, isEmpty);
      expect(state.status, PagedStatus.idle);
      expect(state.page, 0);
      expect(state.hasMore, isFalse);
      expect(state.isEmpty, isTrue);
      expect(state.isLoadingMore, isFalse);
    });

    test('首屏加载写入条目与分页信息', () {
      final PagedState<int> state = const PagedState<int>()
          .startingFirstPage()
          .withFirstPage(<int>[1, 2, 3], page: 1, hasMore: true);

      expect(state.items, <int>[1, 2, 3]);
      expect(state.page, 1);
      expect(state.hasMore, isTrue);
      expect(state.status, PagedStatus.ready);
      expect(state.errorMessage, isNull);
    });

    test('加载下一页追加条目而不是替换', () {
      final PagedState<int> state = const PagedState<int>()
          .withFirstPage(<int>[1, 2], page: 1, hasMore: true)
          .startingNextPage()
          .withNextPage(<int>[3], page: 2, hasMore: false);

      expect(state.items, <int>[1, 2, 3]);
      expect(state.page, 2);
      expect(state.hasMore, isFalse);
    });

    test('失败保留已有条目并记录错误', () {
      final PagedState<int> state = const PagedState<int>()
          .withFirstPage(<int>[1, 2], page: 1, hasMore: true)
          .startingNextPage()
          .failed(StateError('网络中断'));

      expect(state.items, <int>[1, 2]);
      expect(state.hasFailed, isTrue);
      expect(state.status, PagedStatus.failure);
      expect(state.errorMessage, contains('网络中断'));
      expect(state.isLoadingMore, isFalse);
    });

    test('copyWith 可清除错误信息', () {
      final PagedState<int> failed = const PagedState<int>().failed(
        StateError('boom'),
      );
      final PagedState<int> cleared = failed.copyWith(errorMessage: null);

      expect(cleared.errorMessage, isNull);
      expect(cleared.status, PagedStatus.failure);
    });

    test('reset 清空条目但保留游标', () {
      final PagedState<int> state = const PagedState<int>()
          .withFirstPage(<int>[1, 2], page: 3, hasMore: true)
          .reset();

      expect(state.items, isEmpty);
      expect(state.page, 3);
      expect(state.hasMore, isTrue);
    });

    test('withFirstPage 结果不可变', () {
      final List<int> source = <int>[1, 2];
      final PagedState<int> state = const PagedState<int>().withFirstPage(
        source,
        page: 1,
        hasMore: false,
      );
      source.add(3);

      expect(state.items, <int>[1, 2]);
    });
  });
}
