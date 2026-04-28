// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppNotificationController)
final appNotificationControllerProvider = AppNotificationControllerProvider._();

final class AppNotificationControllerProvider
    extends $NotifierProvider<AppNotificationController, AppNotification?> {
  AppNotificationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appNotificationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appNotificationControllerHash();

  @$internal
  @override
  AppNotificationController create() => AppNotificationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppNotification? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppNotification?>(value),
    );
  }
}

String _$appNotificationControllerHash() =>
    r'c5e40c8224f71547e86ba961c9df8d7359529d99';

abstract class _$AppNotificationController extends $Notifier<AppNotification?> {
  AppNotification? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppNotification?, AppNotification?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppNotification?, AppNotification?>,
              AppNotification?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
