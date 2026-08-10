// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_tracker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(statisticsTracker)
final statisticsTrackerProvider = StatisticsTrackerProvider._();

final class StatisticsTrackerProvider
    extends
        $FunctionalProvider<
          StatisticsTracker,
          StatisticsTracker,
          StatisticsTracker
        >
    with $Provider<StatisticsTracker> {
  StatisticsTrackerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statisticsTrackerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statisticsTrackerHash();

  @$internal
  @override
  $ProviderElement<StatisticsTracker> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StatisticsTracker create(Ref ref) {
    return statisticsTracker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatisticsTracker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatisticsTracker>(value),
    );
  }
}

String _$statisticsTrackerHash() => r'f1523b6dde05527cb2d0dd2fe2d54e853132eee7';
