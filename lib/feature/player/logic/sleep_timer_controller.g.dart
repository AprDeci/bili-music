// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_timer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SleepTimerController)
final sleepTimerControllerProvider = SleepTimerControllerProvider._();

final class SleepTimerControllerProvider
    extends $NotifierProvider<SleepTimerController, SleepTimerState> {
  SleepTimerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sleepTimerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sleepTimerControllerHash();

  @$internal
  @override
  SleepTimerController create() => SleepTimerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SleepTimerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SleepTimerState>(value),
    );
  }
}

String _$sleepTimerControllerHash() =>
    r'449c39baafcea3fe467eba6130811a3bbc5a968f';

abstract class _$SleepTimerController extends $Notifier<SleepTimerState> {
  SleepTimerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SleepTimerState, SleepTimerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SleepTimerState, SleepTimerState>,
              SleepTimerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
